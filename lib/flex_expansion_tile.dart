library flex_expansion_tile;

//
// Originally based on custom widget HeaderCard found in flex_color_scheme example
// app, but has been modified and extended to be more generic and useful.
//

import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// Function to check if two colors are visually close to each other.
bool _colorsAreClose(Color a, Color b, bool isLight) {
  final int dR = a.red - b.red;
  final int dG = a.green - b.green;
  final int dB = a.blue - b.blue;
  // Calculating orthogonal distance between colors should take the
  // square root as well, but we don't need that extra compute step.
  // We just need a number to represents some relative closeness of the
  // colors. We use this to determine a level when we should draw a border
  // around our panel.
  // These values were just determined by visually testing what was a good
  // trigger for when the border appeared and disappeared during testing.
  // We get better results if we use a different trigger value for light
  // and dark mode.
  final int distance = dR * dR + dG * dG + dB * dB;
  final int closeTrigger = isLight ? 62 : 100;

  if (distance < closeTrigger) {
    return true;
  } else {
    return false;
  }
}

/// Enables control over a single [FlexExpansionTile]'s expanded/collapsed state.
///
/// It can be useful to expand or collapse an [FlexExpansionTile]
/// programmatically, for example to reconfigure an existing expansion
/// tile based on a system event. To do so, create an [FlexExpansionTile]
/// with an [FlexExpansionTileController] that's owned by a stateful widget
/// or look up the tile's automatically created [FlexExpansionTileController]
/// with [FlexExpansionTileController.of]
///
/// The controller's [expand] and [collapse] methods cause the
/// the [FlexExpansionTile] to rebuild, so they may not be called from
/// a build method.
class FlexExpansionTileController {
  /// Create a controller to be used with [FlexExpansionTile.controller].
  FlexExpansionTileController();

  _FlexExpansionTileState? _state;

  /// Whether the [FlexExpansionTile] built with this controller is in expanded state.
  ///
  /// This property doesn't take the animation into account. It reports `true`
  /// even if the expansion animation is not completed.
  ///
  /// See also:
  ///
  ///  * [expand], which expands the [FlexExpansionTile].
  ///  * [collapse], which collapses the [FlexExpansionTile].
  ///  * [FlexExpansionTile.controller] to create an FlexExpansionTile with a controller.
  bool get isExpanded {
    assert(_state != null);
    return _state!._isExpanded;
  }

  /// Expands the [FlexExpansionTile] that was built with this controller;
  ///
  /// Normally the tile is expanded automatically when the user taps on the header.
  /// It is sometimes useful to trigger the expansion programmatically due
  /// to external changes.
  ///
  /// If the tile is already in the expanded state (see [isExpanded]), calling
  /// this method has no effect.
  ///
  /// Calling this method may cause the [FlexExpansionTile] to rebuild, so it may
  /// not be called from a build method.
  ///
  /// Calling this method will trigger an [FlexExpansionTile.onExpansionChanged] callback.
  ///
  /// See also:
  ///
  ///  * [collapse], which collapses the tile.
  ///  * [isExpanded] to check whether the tile is expanded.
  ///  * [FlexExpansionTile.controller] to create an FlexExpansionTile with a controller.
  void expand() {
    assert(_state != null);
    if (!isExpanded) {
      _state!._toggleExpansion();
    }
  }

  /// Collapses the [FlexExpansionTile] that was built with this controller.
  ///
  /// Normally the tile is collapsed automatically when the user taps on the header.
  /// It can be useful sometimes to trigger the collapse programmatically due
  /// to some external changes.
  ///
  /// If the tile is already in the collapsed state (see [isExpanded]), calling
  /// this method has no effect.
  ///
  /// Calling this method may cause the [FlexExpansionTile] to rebuild, so it may
  /// not be called from a build method.
  ///
  /// Calling this method will trigger an [FlexExpansionTile.onExpansionChanged] callback.
  ///
  /// See also:
  ///
  ///  * [expand], which expands the tile.
  ///  * [isExpanded] to check whether the tile is expanded.
  ///  * [FlexExpansionTile.controller] to create an FlexExpansionTile with a controller.
  void collapse() {
    assert(_state != null);
    if (isExpanded) {
      _state!._toggleExpansion();
    }
  }

  /// Finds the [FlexExpansionTileController] for the closest [FlexExpansionTile] instance
  /// that encloses the given context.
  ///
  /// If no [FlexExpansionTile] encloses the given context, calling this
  /// method will cause an assert in debug mode, and throw an
  /// exception in release mode.
  ///
  /// To return null if there is no [FlexExpansionTile] use [maybeOf] instead.
  ///
  /// {@tool dartpad}
  /// Typical usage of the [FlexExpansionTileController.of] function is to call it from within the
  /// `build` method of a descendant of an [FlexExpansionTile].
  ///
  /// When the [FlexExpansionTile] is actually created in the same `build`
  /// function as the callback that refers to the controller, then the
  /// `context` argument to the `build` function can't be used to find
  /// the [FlexExpansionTileController] (since it's "above" the widget
  /// being returned in the widget tree). In cases like that you can
  /// add a [Builder] widget, which provides a new scope with a
  /// [BuildContext] that is "under" the [FlexExpansionTile]:
  ///
  /// ** See code in examples/api/lib/material/expansion_tile/expansion_tile.1.dart **
  /// {@end-tool}
  ///
  /// A more efficient solution is to split your build function into
  /// several widgets. This introduces a new context from which you
  /// can obtain the [FlexExpansionTileController]. With this approach you
  /// would have an outer widget that creates the [FlexExpansionTile]
  /// populated by instances of your new inner widgets, and then in
  /// these inner widgets you would use [FlexExpansionTileController.of].
  static FlexExpansionTileController of(BuildContext context) {
    final _FlexExpansionTileState? result =
        context.findAncestorStateOfType<_FlexExpansionTileState>();
    if (result != null) {
      return result._tileController;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'FlexExpansionTileController.of() called with a context that does not contain a FlexExpansionTile.',
      ),
      ErrorDescription(
        'No FlexExpansionTile ancestor could be found starting from the context that was passed to FlexExpansionTileController.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the FlexExpansionTile widget being sought.',
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
        'context that is "under" the FlexExpansionTile. For an example of this, please see the '
        'documentation for FlexExpansionTileController.of():\n'
        '  https://api.flutter.dev/flutter/material/FlexExpansionTile/of.html',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the FlexExpansionTile. In this solution, '
        'you would have an outer widget that creates the FlexExpansionTile populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use FlexExpansionTileController.of().\n'
        'An other solution is assign a GlobalKey to the FlexExpansionTile, '
        'then use the key.currentState property to obtain the FlexExpansionTile rather than '
        'using the FlexExpansionTileController.of() function.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Finds the [FlexExpansionTile] from the closest instance of this class that
  /// encloses the given context and returns its [FlexExpansionTileController].
  ///
  /// If no [FlexExpansionTile] encloses the given context then return null.
  /// To throw an exception instead, use [of] instead of this function.
  ///
  /// See also:
  ///
  ///  * [of], a similar function to this one that throws if no [FlexExpansionTile]
  ///    encloses the given context. Also includes some sample code in its
  ///    documentation.
  static FlexExpansionTileController? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<_FlexExpansionTileState>()
        ?._tileController;
  }
}

/// A [Card] with a [ListTile] header that can be toggled via its trailing
/// widget to open and reveal more content provided via [child] in the card.
///
/// The open reveal is animated.
///
/// The ListTile and its revealed child are wrapped in a Card widget. The
/// [FlexExpansionTile] is primarily designed to be placed on [Scaffold] using
/// its themed background color.
///
/// The header and background color of the [Card] get a slight primary color
/// blend added to its default surface color.
/// It always avoids the same color as the scaffold background, for both the
/// list tile heading and the card itself.
///
/// This is a Flutter "Universal" Widget that only depends on the SDK and
/// can be dropped into any application.
class FlexExpansionTile extends StatefulWidget {
  const FlexExpansionTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.info,
    this.trailing,
    this.margin = EdgeInsets.zero,
    this.headerPadding,
    this.headingColor,
    this.elevation = 0,
    this.enabled = true,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.duration = const Duration(milliseconds: 200),
    this.startStraight = false,
    this.endStraight = false,
    this.color,
    this.child,
    this.childPadding,
    this.controller,
    this.controlAffinity,
    this.maintainState = false,
    this.onLongTap,
    this.dense,
    this.subtitleDense,
  });

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  ///
  /// This should not wrap. To enforce the single line limit, use
  /// [Text.maxLines].
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Normal you would not use the property in the FlexExpansionTile, but it
  /// is possible if required.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// Optional expanding info text that can be used to describe content in
  /// this header card.
  ///
  /// If null or empty string, there is no info icon and expand feature.
  final String? info;

  /// A widget to display after the title.
  ///
  /// Typically an [Icon] widget.
  ///
  /// To show right-aligned metadata (assuming left-to-right reading order;
  /// left-aligned for right-to-left reading order), consider using a [Row] with
  /// [CrossAxisAlignment.baseline] alignment whose first item is [Expanded] and
  /// whose second child is the metadata text, instead of using the [trailing]
  /// property.
  final Widget? trailing;

  /// The margins around the entire reveal list tile card.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry margin;

  final GestureTapCallback? onLongTap;

  /// The internal padding of the ListTile used as header.
  ///
  /// Insets the header [ListTile]'s contents:
  /// its [leading], [title], [subtitle].
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry? headerPadding;

  /// The background color for the header.
  ///
  /// If not provided, one that is slightly off from card color
  /// background color is computed.
  final Color? headingColor;

  /// Elevation of the header card.
  ///
  /// Default to 0.
  final double elevation;

  /// Whether this list tile and card operation is interactive.
  final bool enabled;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The duration of the show and hide animation of child.
  final Duration duration;

  /// The start side should be straight, no border radius.
  ///
  /// Defaults to false.
  final bool startStraight;

  /// The end side should be straight, no border radius.
  ///
  /// Defaults to false.
  final bool endStraight;

  /// The end side should be straight, no border radius.
  ///
  /// Defaults to false.
  final bool? dense;

  /// The end side should be straight, no border radius.
  ///
  /// Defaults to false.
  final bool? subtitleDense;

  /// Specifies whether the state of the child is maintained when the tile expands and collapses.
  ///
  /// When true, the child is kept in the tree while the tile is collapsed.
  /// When false (default), the child is removed from the tree when the tile is
  /// collapsed and recreated upon expansion.
  final bool maintainState;

  /// Define this color to override that automatic adaptive background color.
  final Color? color;

  /// The child to be revealed.
  final Widget? child;

  // The padding of the child. if null then EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0) is used.
  final EdgeInsetsGeometry? childPadding;

  /// Typically used to force the expansion arrow icon to the tile's leading or trailing edge.
  ///
  /// By default, the value of [controlAffinity] is [ListTileControlAffinity.platform],
  /// which means that the expansion arrow icon will appear on the tile's trailing edge.
  final ListTileControlAffinity? controlAffinity;

  /// If provided, the controller can be used to expand and collapse tiles.
  ///
  /// In cases were control over the tile's state is needed from a callback triggered
  /// by a widget within the tile, [FlexExpansionTileController.of] may be more convenient
  /// than supplying a controller.
  final FlexExpansionTileController? controller;

  @override
  State<FlexExpansionTile> createState() => _FlexExpansionTileState();
}

class _FlexExpansionTileState extends State<FlexExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  bool _isExpanded = false;
  late FlexExpansionTileController _tileController;
  late AnimationController _animationController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _animationController.drive(_easeInTween);

    _isExpanded = PageStorage.maybeOf(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;

    if (_isExpanded) {
      _animationController.value = 1.0;
    }

    assert(widget.controller?._state == null);
    _tileController = widget.controller ?? FlexExpansionTileController();
    _tileController._state = this;
  }

  @override
  void dispose() {
    _tileController._state = null;
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse().then<void>((void value) {
          if (!mounted) {
            return;
          }
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.maybeOf(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget? _buildIcon(BuildContext context) {
    return ExpandIcon(
      size: 32,
      isExpanded: _isExpanded,
      padding: EdgeInsets.zero,
      onPressed: (_) {
        _toggleExpansion();
      },
    );
  }

  // Platform or null affinity defaults to trailing.
  ListTileControlAffinity _effectiveAffinity(
      ListTileControlAffinity? affinity) {
    switch (affinity ?? ListTileControlAffinity.trailing) {
      case ListTileControlAffinity.leading:
        return ListTileControlAffinity.leading;
      case ListTileControlAffinity.trailing:
      case ListTileControlAffinity.platform:
        return ListTileControlAffinity.trailing;
    }
  }

  Widget? _buildLeadingIcon(BuildContext context) {
    if (_effectiveAffinity(widget.controlAffinity) !=
        ListTileControlAffinity.leading) {
      return null;
    }
    return _buildIcon(context);
  }

  Widget? _buildTrailingIcon(BuildContext context) {
    if (_effectiveAffinity(widget.controlAffinity) !=
            ListTileControlAffinity.trailing ||
        !widget.enabled) {
      return null;
    }
    return _buildIcon(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _animationController.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;
    final ThemeData theme = Theme.of(context);
    final bool isLight = theme.brightness == Brightness.light;
    final bool useMaterial3 = theme.useMaterial3;
    final ColorScheme scheme = theme.colorScheme;
    final Color background = theme.scaffoldBackgroundColor;

    final Color cardColor = widget.color ?? theme.cardColor;
    // Compute a header color with fixed primary blend from the card color,
    // if one was not provided
    final Color headerColor = widget.headingColor ??
        Color.alphaBlend(
            scheme.surfaceTint.withAlpha(isLight ? 10 : 16), cardColor);

    final bool useHeading = widget.title != null ||
        widget.subtitle != null ||
        widget.leading != null;

    // Default starting point value based on M3 and M2 mode spec values.
    double borderRadius = useMaterial3 ? 12 : 4;
    // Is themed? Try to get the radius from the theme and used that if it was.
    final ShapeBorder? cardShape = theme.cardTheme.shape;
    if (cardShape != null && cardShape is RoundedRectangleBorder) {
      final BorderRadius shape = cardShape.borderRadius as BorderRadius;
      borderRadius = shape.bottomLeft.x;
    }
    final bool useBorderSide =
        _colorsAreClose(cardColor, background, isLight) ||
            (useHeading && _colorsAreClose(headerColor, background, isLight));
    final ShapeBorder shapeBorder = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        start:
            widget.startStraight ? Radius.zero : Radius.circular(borderRadius),
        end: widget.endStraight ? Radius.zero : Radius.circular(borderRadius),
      ),
      side: useBorderSide
          ? BorderSide(
              color: theme.dividerColor,
              width: 0.7, // This gives a hairline 1 pc border
            )
          : BorderSide.none,
    );
    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
            padding: widget.childPadding ??
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: widget.child),
      ),
    );

    return FocusTraversalGroup(
      child: Card(
        margin: widget.margin,
        shape: shapeBorder,
        elevation: widget.elevation,
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: <Widget>[
            if (useHeading)
              Material(
                type: MaterialType.card,
                color: headerColor,
                child: _ListTileReveal(
                  contentPadding: widget.headerPadding,
                  enabled: widget.enabled,
                  dense: widget.dense,
                  subtitleDense: widget.subtitleDense,
                  leading: widget.leading ?? _buildLeadingIcon(context),
                  title: widget.title,
                  subtitle: widget.info != null && widget.info != ''
                      ? Text(widget.info!)
                      : null,
                  trailing: widget.trailing ?? _buildTrailingIcon(context),
                  onTap: _toggleExpansion,
                  onLongTap: widget.onLongTap,
                ),
              ),
            AnimatedBuilder(
              animation: _animationController.view,
              builder: (context, child) => ClipRect(
                  child:
                      Align(heightFactor: _heightFactor.value, child: child)),
              child: shouldRemoveChildren ? null : result,
            )
          ],
        ),
      ),
    );
  }
}

/// A custom [ListTile] that has a built-in animated custom leading action
/// after the [leading] widget built in as a part of [title] that
/// reveals the [subtitle] when clicked.
///
/// This is useful when a more compact look is desired where more information
/// is provided as an optional user based reveal action. The purpose is to make
/// UI less talkative but provide easy access to additional usage explanation.
///
/// This is a Flutter "Universal" Widget that only depends on the SDK and
/// can be dropped into any application.
class _ListTileReveal extends StatefulWidget {
  const _ListTileReveal({
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.onTap,
    this.dense,
    this.subtitleDense,
    this.enabled = true,
    this.onLongTap,
  });

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  ///
  /// This should not wrap. To enforce the single line limit, use
  /// [Text.maxLines].
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// A widget to display after the title.
  ///
  /// Typically an [Icon] widget.
  ///
  /// To show right-aligned metadata (assuming left-to-right reading order;
  /// left-aligned for right-to-left reading order), consider using a [Row] with
  /// [CrossAxisAlignment.baseline] alignment whose first item is [Expanded] and
  /// whose second child is the metadata text, instead of using the [trailing]
  /// property.
  final Widget? trailing;

  /// The [ListTileReveal]'s internal padding.
  ///
  /// Insets a [ListTileReveal]'s contents: its [leading], [title], [subtitle],
  /// and [trailing] widgets.
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry? contentPadding;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  /// Called when the user long taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onLongTap;

  /// Whether this list tile and card operation is interactive.
  final bool enabled;

  /// Whether this list tile is part of a vertically dense list.
  ///
  /// If this property is null then its value is based on [ListTileTheme.dense].
  ///
  /// Dense list tiles default to a smaller height.
  final bool? dense;

  /// Whether this list tile subtitle is dense.
  ///
  /// Dense list tiles default to a smaller height. The subtitle is also dense
  /// if dense is true.
  ///
  /// If not defined defaults to false.
  final bool? subtitleDense;

  @override
  State<_ListTileReveal> createState() => _ListTileRevealState();
}

class _ListTileRevealState extends State<_ListTileReveal> {
  bool _isOpen = false;

  void _handleTap() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          enabled: widget.enabled,
          contentPadding: widget.contentPadding,
          leading: widget.leading,
          dense: widget.dense,
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (widget.title != null) widget.title!,
              if (widget.subtitle != null && widget.enabled)
                IconButton(
                  iconSize: 20,
                  // ignore: avoid_bool_literals_in_conditional_expressions
                  isSelected: widget.enabled ? _isOpen : false,
                  icon: const Icon(Icons.info_outlined),
                  selectedIcon: const Icon(Icons.info),
                  onPressed: widget.enabled ? _handleTap : null,
                ),
            ],
          ),
          trailing: widget.trailing,
          onTap: widget.enabled ? widget.onTap : null,
          onLongPress: widget.enabled ? widget.onLongTap : null,
        ),
        AnimatedSwitcher(
          duration: _kExpand,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: (_isOpen && widget.subtitle != null && widget.enabled)
              ? ListTile(
                  dense: (widget.dense ?? false) ||
                      (widget.subtitleDense ?? false),
                  title: DefaultTextStyle(
                      style:
                          Theme.of(context).listTileTheme.subtitleTextStyle ??
                              Theme.of(context).textTheme.bodySmall!,
                      child: widget.subtitle!),
                  onTap: widget.enabled ? _handleTap : null,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

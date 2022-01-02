import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final CountryTileBuilder? countryTileBuilder;
  final CountriesListSeparatorBuilder? countriesListSeparatorBuilder;
  final CountriesListHeaderBuilder? countriesListHeaderBuilder;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;

  CountrySearchListWidget(
    this.countries,
    this.locale, {
    this.searchBoxDecoration,
    this.countryTileBuilder,
    this.countriesListSeparatorBuilder,
    this.countriesListHeaderBuilder,
    this.scrollController,
    this.showFlags,
    this.useEmoji,
    this.autoFocus = false,
  });

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(labelText: 'Search by country name or dial code');
  }

  @override
  Widget build(BuildContext context) {
    final searchBox = TextFormField(
      key: Key(TestHelper.CountrySearchInputKeyValue),
      decoration: getSearchBoxDecoration(),
      controller: _searchController,
      autofocus: widget.autoFocus,
      onChanged: (value) {
        final String value = _searchController.text.trim();
        return setState(
          () => filteredCountries = Utils.filterCountries(
            countries: widget.countries,
            locale: widget.locale,
            value: value,
          ),
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        widget.countriesListHeaderBuilder != null
            ? widget.countriesListHeaderBuilder!(searchBox: searchBox)
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: searchBox,
              ),
        Flexible(
          child: widget.countriesListSeparatorBuilder != null
              ? ListView.separated(
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  itemBuilder: buildCountryListTile,
                  separatorBuilder: (context, index) =>
                      widget.countriesListSeparatorBuilder!(),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  itemBuilder: buildCountryListTile,
                ),
        ),
      ],
    );
  }

  /// Builds a list tile with [index] for countries list.
  Widget buildCountryListTile(BuildContext context, int index) {
    Country country = filteredCountries[index];

    if (widget.countryTileBuilder != null) {
      return widget.countryTileBuilder!(
        tileKey: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
        countryName: '${Utils.getCountryName(country, widget.locale)}',
        flag: (widget.showFlags!
            ? _Flag(country: country, useEmoji: widget.useEmoji!)
            : null),
        dialCode: country.dialCode,
        onTap: () => Navigator.of(context).pop(country),
      );
    }

    return DirectionalCountryListTile(
      country: country,
      locale: widget.locale,
      showFlags: widget.showFlags!,
      useEmoji: widget.useEmoji!,
    );
  }

  Widget buildCountryListSeparator(BuildContext context, int index) {
    if (widget.countriesListSeparatorBuilder != null) {
      return widget.countriesListSeparatorBuilder!();
    } else {
      return Container();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;
  final bool showFlags;
  final bool useEmoji;

  const DirectionalCountryListTile({
    Key? key,
    required this.country,
    required this.locale,
    required this.showFlags,
    required this.useEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
      leading: (showFlags ? _Flag(country: country, useEmoji: useEmoji) : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${Utils.getCountryName(country, locale)}',
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        ),
      ),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${country.dialCode ?? ''}',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
        ),
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? useEmoji;

  const _Flag({Key? key, this.country, this.useEmoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
            child: useEmoji!
                ? Text(
                    Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                    style: Theme.of(context).textTheme.headline5,
                  )
                : country?.flagUri != null
                    ? CircleAvatar(
                        backgroundImage: AssetImage(
                          country!.flagUri,
                          package: 'intl_phone_number_input',
                        ),
                      )
                    : SizedBox.shrink(),
          )
        : SizedBox.shrink();
  }
}

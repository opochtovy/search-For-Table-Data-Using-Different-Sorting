search-For-Table-Data-Using-Different-Sorting
================================================

API illustrates as one data set can be transformed into another, more structured, using filters (text in search bar).

During my app’s realization I touched the following topics:

- blocks;
- NSOperations and NSQueue; 
- UISearchBar, UISegmentedControl, UITableView;
- custom type of data;
- NSSortDescriptor;
- NSDateFormatter.

Key features of the app:

1. generation of a random number of students and displaying them in the table;
2. grouping students in sections depending on selected segment of SegmentedControl;
3. sorting students inside each section depending on selected segment of SegmentedControl using NSSortDescriptor;
4. using the index bar to jump to sections;
5. filtering students every time a new character is added to search bar text, and looking for matches like in the first name and in the last name;
6. using NSOperations to sort our array in background threadt;
6. using NSQueue to cancel all previous NSOperations when we get new search text;
7. integration of UISegmentedControl to illustrate 3 ways of grouping our student array into according sections.
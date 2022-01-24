# MovieBook
Experimental App that can search for movies using the IMDB API. The project makes use of `Combine` where applicable.

<img src="readme-sources/search-result-1.png" alt="Search Results" width="300"/>


Doing following things with Combine:

* A generic network layer that can decode any Network response to the specified `Decodable` object: See `NetworkManager`
* Transforming decoded network result and errors into UI models. See `MovieSearchViewModel`
* Filtering and debouncing the search input to avoid unnecessary queries. See: `MovieSearchViewController`

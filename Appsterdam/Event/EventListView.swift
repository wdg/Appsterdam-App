//
//  EventView.swift
//  Appsterdam
//
//  Created by Wesley de Groot on 22/01/2022.
//

import SwiftUI
import Aurora
import UIKit

struct EventListView: View {
    @State private var searchText = ""
    @State private var showsEvent: Bool = false
    @State private var showEvent: Event = .init(
        id: "0",
        name: "",
        description: "",
        price: "0",
        organizer: "Appsterdam",
        location_name: "",
        location_address: "",
        date: "",
        attendees: "0",
        icon: "",
        latitude: "",
        longitude: ""
    )

    private let events = Model<EventModel>.init(
        url: "https://appsterdam.rs/api/events.json"
    ).load()

    var body: some View {
        List() {
            TextField("Search", text: $searchText)
                .padding(7)
                .padding(.horizontal, 20)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                )
                .padding(.horizontal, 0)

            ForEach(searchResults) { section in
                Section(header: Text(section.name)) {
                    ForEach(section.events) { event in
                        EventCell(event: event)
                            .onTapGesture {
                                self.showEvent = event
                                self.showsEvent.toggle()
                               // for some reason,
                               // the list scrolls to the top when opening an
                               // item, i cant figure out (yet) how to fix this
                            }
                    }
                }
                .headerProminence(.increased)
            }
        }
        .fullScreenCover(isPresented: $showsEvent, content: {
            EventView(displayEvent: $showEvent)
        })
    }

    var searchResults: [EventModel] {
        if searchText.isEmpty {
            return events
        } else {
            var searchEvents: [EventModel] = [EventModel]()

            for section in events {
                var searchEvent: [Event] = [Event]()

                for event in section.events {
                    if (
                        event.name.contains(search: searchText) ||
                        event.description.contains(search: searchText) ||
                        event.date.contains(search: searchText)
                    ) {
                        searchEvent.append(event)
                    }
                }

                if !searchEvent.isEmpty {
                    searchEvents.append(
                        .init(
                            name: section.name,
                            events: searchEvent
                        )
                    )
                }
            }

            // if no results then return no results found...
            guard !searchEvents.isEmpty else {
                return [
                    .init(
                        name: "No results found",
                        events: [
                            .init(
                                id: "0",
                                name: "No result found",
                                description: "Please try another search.",
                                price: "0",
                                organizer: "",
                                location_name: "",
                                location_address: "",
                                date: "",
                                attendees: "0",
                                icon: "exclamationmark.arrow.triangle.2.circlepath",
                                latitude: "",
                                longitude: ""
                            )
                        ]
                    )
                ]
            }

            return searchEvents
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}

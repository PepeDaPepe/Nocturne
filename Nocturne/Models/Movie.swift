import Foundation

struct Movie: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let year: String
    let director: String
    let runtime: Int
    let rating: Double
    let posterName: String
    let backdropName: String
    let synopsis: String
    var isWatchlisted: Bool = false
}

extension Movie {
    static let featuredDune = Movie(
        title: "Dune: Parte Due",
        year: "2024",
        director: "Denis Villeneuve",
        runtime: 166,
        rating: 8.8,
        posterName: "dune_backdrop",
        backdropName: "dune_backdrop",
        synopsis: "Paul Atreides si unisce a Chani e ai Fremen mentre trama la vendetta contro i cospiratori che hanno distrutto la sua famiglia. Di fronte a una scelta tra l'amore della sua vita e il destino dell'universo, cerca di prevenire un terribile futuro."
    )
    
    static let sampleTopRated: [Movie] = [
        Movie(
            title: "Oppenheimer",
            year: "2023",
            director: "Christopher Nolan",
            runtime: 180,
            rating: 8.9,
            posterName: "oppenheimer_poster",
            backdropName: "dune_backdrop",
            synopsis: "La storia del fisico americano J. Robert Oppenheimer e del suo ruolo nello sviluppo della bomba atomica durante il Progetto Manhattan."
        ),
        Movie(
            title: "Past Lives",
            year: "2023",
            director: "Celine Song",
            runtime: 106,
            rating: 8.6,
            posterName: "pastlives_poster",
            backdropName: "dune_backdrop",
            synopsis: "Nora e Hae Sung, due amici d'infanzia profondamente legati, si separano quando la famiglia di Nora emigra dalla Corea del Sud. Due decenni dopo si ritrovano a New York per una settimana fatidica."
        ),
        Movie(
            title: "Anatomia di una caduta",
            year: "2023",
            director: "Justine Triet",
            runtime: 152,
            rating: 8.5,
            posterName: "anatomia_poster",
            backdropName: "dune_backdrop",
            synopsis: "Una donna viene sospettata dell'omicidio del marito dopo una misteriosa caduta nelle Alpi francesi; il loro figlio ipovedente affronta un dilemma morale come unico testimone."
        )
    ]
    
    static let sampleTop250Preview: [Movie] = [
            Movie(
                title: "Le ali della libertà",
                year: "1994",
                director: "Darabont",
                runtime: 142,
                rating: 9.3,
                posterName: "shawshank_poster",
                backdropName: "dune_backdrop",
                synopsis: "Due uomini imprigionati stringono un legame lungo diversi anni, trovando conforto ed eventuale redenzione attraverso atti di decenza comune."
            ),
            Movie(
                title: "Il padrino",
                year: "1972",
                director: "Coppola",
                runtime: 175,
                rating: 9.2,
                posterName: "godfather_poster",
                backdropName: "dune_backdrop",
                synopsis: "Il patriarca di una dinastia criminale trasferisce il controllo del suo impero clandestino al figlio riluttante."
            ),
            Movie(
                title: "Il cavaliere oscuro",
                year: "2008",
                director: "Nolan",
                runtime: 152,
                rating: 9.0,
                posterName: "darkknight_poster",
                backdropName: "dune_backdrop",
                synopsis: "Quando la minaccia nota come Joker semina il caos a Gotham, Batman deve affrontare una delle più grandi prove psicologiche e fisiche."
            )
        ]
}



# 🎬 Nocturne
Gruppo:
Joao Pedro Fischer da Silva (Rete & API,Database & Logica Utente)
Simone Attanasio (Rete & API,Database & Logica Utente)
Filippo Molgora (UI & Design)

**Nocturne** è un'applicazione iOS sviluppata in SwiftUI, ispirata a *Letterboxd*, pensata per scoprire nuovi film, gestire una **Watchlist** personale e tenere un **Diario** dei film visti con voti e recensioni.

## 📱 Cosa fa l'app

* **Scoperta (Home):** Mostra i film del momento, la classifica dei più votati, i filtri per genere e una sezione di consigli personalizzati.
* **Ricerca (Cerca):** Permette di cercare in tempo reale qualsiasi film, regista o attore ed esplorare i cataloghi per genere.
* **Diario e Recensioni (+ Log):** Permette di registrare un film visto, assegnare un voto da 0.5 a 5 stelle (anche trascinando il dito), aggiungere un "Mi piace", indicare dove lo si è visto (es. Sala, IMAX, Casa) e scrivere una recensione.
* **Watchlist:** Divide i film tra *"Da Vedere"* e *"Film Visti"*, permettendo di segnarli come visti o rimuoverli.
* **Profilo Utente:** Mostra i dati dell'utente, i 4 film preferiti, le statistiche aggiornate in automatico, il grafico della distribuzione dei voti e lo storico delle recensioni.

---

## ✅ Cosa siamo riusciti a fare

* **Interfaccia grafica completa:** Tutte le schermate principali e la barra di navigazione personalizzata sono state realizzate seguendo il design scuro (*Dark Mode*) progettato nei mockup.
* **Dati reali da internet (API TMDB):** L'app è collegata al database online di *TMDB* e scarica dal vivo titoli, trame, voti medi e locandine ufficiali.
* **Ricerca e Filtri funzionanti:** Funziona sia la ricerca per titolo/regista/attore, sia il filtro per tutti i generi cinematografici ufficiali.
* **Salvataggio permanente sul telefono (SwiftData):** I film aggiunti in Watchlist, le recensioni scritte, i voti e le modifiche al profilo vengono salvati davvero nella memoria del dispositivo e aggiornano in tempo reale statistiche e grafici.
* **Consigliati per Te dinamici:** L'app analizza i film salvati o votati dall'utente per proporre titoli simili tramite TMDB.

---

## 🚧 Cosa non siamo riusciti a fare

* **Funzioni Social e Account Online:** L'app funziona interamente in locale sul telefono; non c'è un server esterno per avere utenti reali, amicizie, like o commenti di altre persone.
* **Alcuni pulsanti secondari solo grafici:** Il tasto *"Carica altri film"* in fondo alle griglie, il menu per cambiare l'ordine delle liste, il tasto *Play* per i trailer e la scelta della foto profilo dalla galleria sono presenti nel design ma non sono ancora collegati.
* **Dettagli secondari nelle liste:** Nelle anteprime rapide, alcuni dati come la durata esatta in minuti usano un valore standard perché TMDB non li invia nelle liste generali.

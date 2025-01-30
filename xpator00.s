; Autor reseni: vaclav patorek xpator00

; Projekt 2 - INP 2024
; Vigenerova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "vaclavpatorek" ; sem doplnte vase "jmenoprijmeni"
cipher:         .space  31 ; misto pro zapis zasifrovaneho textu
; zde si muzete nadefinovat vlastni promenne ci konstanty,
; napr. hodnoty posuvu pro jednotlive znaky sifrovacho klice

sifrovaci_klic_pat: .byte 112, 97, 116 ; Sifrovaci klic "pat" v ASCII hodnotach (p = 112, a = 97, t = 116), "p" se posune o 16 pozic, "a" se posune o 1 pozici, "t" se posune o 20 pozic

params_sys5:    .space  8 ; misto pro ulozeni adresy pocatku
                          ; retezce pro vypis pomoci syscall 5
                          ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

main:           ; ZDE NAHRADTE KOD VASIM RESENIM
                ; Inicializace zakladnich promennych do registru
                daddi r1, r0, 1 ; r1 = ridi smer sifrovani (1 = posun vpred, 0 = posun vzad)
                daddi r2, r0, 0 ; r2 = pozice ve vstupnim nebo vystupnim textu
                daddi r3, r0, 0 ; r3 = pozice v sifrovacim klici "pat"

zpracuj:
                lb r4, msg(r2) ; Nacte se znak ze vstupu do r4
                beqz r4, konec ; Pokud je znak roven 0, tak nasleduje konec retezce a skoci na konec

                ; Nacteni a uprava hodnoty sifrovacího klice "pat"
                lb r5, sifrovaci_klic_pat(r3) ; Znak sifrovacího klice "pat" se nacte do r5
                daddi r5, r5, -96 ; Prevedeme ASCII hodnotu na hodnotu posunu (a = 1, b = 2, c = 3, ..., z = 26)

                ; Rozhodnuti o smeru posunu
                beqz r1, posun_smer_minus ; Pokud se r1 rovna 0, provede se posun dozadu

posun_smer_plus:
                dadd r6, r4, r5 ; Pricte posun dopredu ke znaku
                daddi r7, r0, 122 ; r7 = ASCII hodnota pro pismeno "z"
                slt r8, r7, r6 ; r8 = rovna se 1 pokud vysledek pretekl pismeno "z"
                beqz r8, zapis ; Pokud vysledek nepretekl, tak ho muzeme vypsat
                daddi r6, r6, -26 ; Pokud vysledek pretekl, tak odecteme ASCII hodnotu 26
                j zapis ; Skok na zapsani znaku po preteceni pismena "z"

posun_smer_minus:
                dsub r6, r4, r5 ; Odecte posun dozadu ke znaku
                daddi r7, r0, 97 ; r7 = ASCII hodnota pro pismeno "a"
                slt r8, r6, r7 ; r8 = rovna se 1 pokud vysledek pretekl pismeno "a" (dozadu pozpatku jakoby)
                beqz r8, zapis ; Pokud vysledek nepretekl, tak ho muzeme vypsat
                daddi r6, r6, 26 ; Pokud vysledek pretekl, tak pricteme ASCII hodnotu 26

zapis:
                sb r6, cipher(r2) ; Zapise sifrovany znak na vystup
                ; Aktualizace indexu
                daddi r2, r2, 1 ; Posune na dalsi znak textu
                daddi r3, r3, 1 ; Posune na dalsi znak sifrovaciho klice "pat"
                slti r8, r3, 3 ; Testujeme, jestli index sifrovaciho klice "pat" je mensi nez 3
                bnez r8, dalsi ; Pokud je index sifrovaciho klice "pat" mensi nez 3, tak pokracujeme
                daddi r3, r0, 0 ; Pokud neni index sifrovaciho klice "pat" mensi nez 3, tak vraci index sifrovaciho klice na 0

dalsi:
                xori r1, r1, 1 ; Zmeni sifrovani (1 -> 0 nebo 0 -> 1)
                j zpracuj ; Zpracuje dalsi znak

konec:
                sb r0, cipher(r2) ; Prida ukoncovaci nulu na konec vystupu
                daddi r4, r0, cipher ; Pripravi adresu pro vypis
                jal print_string ; Zavola funkci pro vypis


; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address

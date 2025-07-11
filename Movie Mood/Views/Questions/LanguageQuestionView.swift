import SwiftUI

struct LanguageQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var movieListVM: MovieListViewModel

    var body: some View {
        let allLanguages = filterVM.allLanguages(from: movieListVM)
        let isAnySelected = !filterVM.options.selectedLanguage.isEmpty
        let languageNames: [String: String] = ["en": "English", "fr": "French", "de": "German", "tr": "Turkish", "es": "Spanish", "it": "Italian", "ja": "Japanese", "ko": "Korean", "zh": "Chinese", "ru": "Russian", "ar": "Arabic", "hi": "Hindi", "pt": "Portuguese", "nl": "Dutch", "sv": "Swedish", "da": "Danish", "no": "Norwegian", "fi": "Finnish", "pl": "Polish", "cs": "Czech", "hu": "Hungarian", "ro": "Romanian", "bg": "Bulgarian", "hr": "Croatian", "sk": "Slovak", "sl": "Slovenian", "et": "Estonian", "lv": "Latvian", "lt": "Lithuanian", "mt": "Maltese", "el": "Greek", "he": "Hebrew", "fa": "Persian", "th": "Thai", "vi": "Vietnamese", "id": "Indonesian", "ms": "Malay", "tl": "Filipino", "bn": "Bengali", "ta": "Tamil", "te": "Telugu", "kn": "Kannada", "ml": "Malayalam", "gu": "Gujarati", "pa": "Punjabi", "mr": "Marathi", "ne": "Nepali", "si": "Sinhala", "my": "Burmese", "km": "Khmer", "lo": "Lao", "ka": "Georgian", "am": "Amharic", "sw": "Swahili", "zu": "Zulu", "af": "Afrikaans", "sq": "Albanian", "hy": "Armenian", "az": "Azerbaijani", "eu": "Basque", "be": "Belarusian", "bs": "Bosnian", "ca": "Catalan", "cy": "Welsh", "eo": "Esperanto", "fo": "Faroese", "fy": "Frisian", "gl": "Galician", "is": "Icelandic", "ga": "Irish", "kk": "Kazakh", "ky": "Kyrgyz", "lb": "Luxembourgish", "mk": "Macedonian", "mn": "Mongolian", "me": "Montenegrin", "ps": "Pashto", "qu": "Quechua", "rm": "Romansh", "sm": "Samoan", "gd": "Scottish Gaelic", "sr": "Serbian", "sn": "Shona", "so": "Somali", "su": "Sundanese", "tg": "Tajik", "tk": "Turkmen", "uk": "Ukrainian", "uz": "Uzbek", "yi": "Yiddish"]
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Original language?")
                .font(.title2.bold())
            if allLanguages.isEmpty {
                ProgressView("Loading languages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    let allWithAny = ["ANY"] + allLanguages
                    WrapHStack(allWithAny, id: \.self) { lang in
                        ChipView(
                            text: lang == "ANY" ? "Any" : (languageNames[lang] ?? lang.uppercased()),
                            isSelected: lang == "ANY" ? !isAnySelected : filterVM.options.selectedLanguage == lang
                        ) {
                            if lang == "ANY" {
                                filterVM.options.selectedLanguage = ""
                            } else {
                                filterVM.options.selectedLanguage = lang
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
} 
import 'package:app_filmes/model/filme_model.dart';

/// Sugestão de título.
class Recomendacao {
  final String titulo;
  final int ano;
  final TipoTitulo tipo;
  final String genero;

  const Recomendacao(this.titulo, this.ano, this.tipo, this.genero);
}

/// Sugestões por gênero (nomes iguais aos do formulário).
const Map<String, List<Recomendacao>> catalogoRecomendacoes = {
  'Ficção científica': [
    Recomendacao('Duna: Parte Dois', 2024, TipoTitulo.filme, 'Ficção científica'),
    Recomendacao('The Expanse', 2015, TipoTitulo.serie, 'Ficção científica'),
    Recomendacao('Blade Runner 2049', 2017, TipoTitulo.filme, 'Ficção científica'),
    Recomendacao('Ex Machina', 2015, TipoTitulo.filme, 'Ficção científica'),
    Recomendacao('Black Mirror', 2011, TipoTitulo.serie, 'Ficção científica'),
  ],
  'Drama': [
    Recomendacao('Whiplash', 2014, TipoTitulo.filme, 'Drama'),
    Recomendacao('Succession', 2018, TipoTitulo.serie, 'Drama'),
    Recomendacao('Manchester à Beira-Mar', 2016, TipoTitulo.filme, 'Drama'),
    Recomendacao('Em Busca da Felicidade', 2006, TipoTitulo.filme, 'Drama'),
  ],
  'Ação': [
    Recomendacao('Mad Max: Estrada da Fúria', 2015, TipoTitulo.filme, 'Ação'),
    Recomendacao('John Wick', 2014, TipoTitulo.filme, 'Ação'),
    Recomendacao('Top Gun: Maverick', 2022, TipoTitulo.filme, 'Ação'),
    Recomendacao('Reacher', 2022, TipoTitulo.serie, 'Ação'),
  ],
  'Comédia': [
    Recomendacao('Se Beber, Não Case!', 2009, TipoTitulo.filme, 'Comédia'),
    Recomendacao('Ted Lasso', 2020, TipoTitulo.serie, 'Comédia'),
    Recomendacao('Brooklyn Nine-Nine', 2013, TipoTitulo.serie, 'Comédia'),
    Recomendacao('Superbad', 2007, TipoTitulo.filme, 'Comédia'),
  ],
  'Terror': [
    Recomendacao('Hereditário', 2018, TipoTitulo.filme, 'Terror'),
    Recomendacao('Corra!', 2017, TipoTitulo.filme, 'Terror'),
    Recomendacao('A Maldição da Residência Hill', 2018, TipoTitulo.serie, 'Terror'),
    Recomendacao('O Iluminado', 1980, TipoTitulo.filme, 'Terror'),
  ],
  'Animação': [
    Recomendacao('Homem-Aranha: Através do Aranhaverso', 2023, TipoTitulo.filme, 'Animação'),
    Recomendacao('Arcane', 2021, TipoTitulo.serie, 'Animação'),
    Recomendacao('A Viagem de Chihiro', 2001, TipoTitulo.filme, 'Animação'),
    Recomendacao('Soul', 2020, TipoTitulo.filme, 'Animação'),
  ],
  'Documentário': [
    Recomendacao('Our Planet', 2019, TipoTitulo.serie, 'Documentário'),
    Recomendacao('O Dilema das Redes', 2020, TipoTitulo.filme, 'Documentário'),
    Recomendacao('Free Solo', 2018, TipoTitulo.filme, 'Documentário'),
    Recomendacao('Making a Murderer', 2015, TipoTitulo.serie, 'Documentário'),
  ],
  'Romance': [
    Recomendacao('La La Land', 2016, TipoTitulo.filme, 'Romance'),
    Recomendacao('Questão de Tempo', 2013, TipoTitulo.filme, 'Romance'),
    Recomendacao('Bridgerton', 2020, TipoTitulo.serie, 'Romance'),
    Recomendacao('Normal People', 2020, TipoTitulo.serie, 'Romance'),
  ],
  'Fantasia': [
    Recomendacao('O Senhor dos Anéis: A Sociedade do Anel', 2001, TipoTitulo.filme, 'Fantasia'),
    Recomendacao('Game of Thrones', 2011, TipoTitulo.serie, 'Fantasia'),
    Recomendacao('O Labirinto do Fauno', 2006, TipoTitulo.filme, 'Fantasia'),
    Recomendacao('The Witcher', 2019, TipoTitulo.serie, 'Fantasia'),
  ],
  'Suspense': [
    Recomendacao('Garota Exemplar', 2014, TipoTitulo.filme, 'Suspense'),
    Recomendacao('Ilha do Medo', 2010, TipoTitulo.filme, 'Suspense'),
    Recomendacao('Mindhunter', 2017, TipoTitulo.serie, 'Suspense'),
    Recomendacao('Dark', 2017, TipoTitulo.serie, 'Suspense'),
  ],
  'Aventura': [
    Recomendacao('Indiana Jones e os Caçadores da Arca Perdida', 1981, TipoTitulo.filme, 'Aventura'),
    Recomendacao('Piratas do Caribe: A Maldição do Pérola Negra', 2003, TipoTitulo.filme, 'Aventura'),
    Recomendacao('Na Natureza Selvagem', 2007, TipoTitulo.filme, 'Aventura'),
    Recomendacao('O Regresso', 2015, TipoTitulo.filme, 'Aventura'),
  ],
  'Musical': [
    Recomendacao('Moulin Rouge!', 2001, TipoTitulo.filme, 'Musical'),
    Recomendacao('O Rei do Show', 2017, TipoTitulo.filme, 'Musical'),
    Recomendacao('Mamma Mia!', 2008, TipoTitulo.filme, 'Musical'),
    Recomendacao('Cantando na Chuva', 1952, TipoTitulo.filme, 'Musical'),
  ],
  'Histórico': [
    Recomendacao('Oppenheimer', 2023, TipoTitulo.filme, 'Histórico'),
    Recomendacao('Chernobyl', 2019, TipoTitulo.serie, 'Histórico'),
    Recomendacao('A Lista de Schindler', 1993, TipoTitulo.filme, 'Histórico'),
    Recomendacao('The Crown', 2016, TipoTitulo.serie, 'Histórico'),
  ],
  'Guerra': [
    Recomendacao('Dunkirk', 2017, TipoTitulo.filme, 'Guerra'),
    Recomendacao('Band of Brothers', 2001, TipoTitulo.serie, 'Guerra'),
    Recomendacao('1917', 2019, TipoTitulo.filme, 'Guerra'),
    Recomendacao('O Resgate do Soldado Ryan', 1998, TipoTitulo.filme, 'Guerra'),
  ],
  'Crime': [
    Recomendacao('Breaking Bad', 2008, TipoTitulo.serie, 'Crime'),
    Recomendacao('O Poderoso Chefão', 1972, TipoTitulo.filme, 'Crime'),
    Recomendacao('Peaky Blinders', 2013, TipoTitulo.serie, 'Crime'),
    Recomendacao('Cidade de Deus', 2002, TipoTitulo.filme, 'Crime'),
  ],
  'Família': [
    Recomendacao('Paddington 2', 2017, TipoTitulo.filme, 'Família'),
    Recomendacao('Matilda', 1996, TipoTitulo.filme, 'Família'),
    Recomendacao('Esqueceram de Mim', 1990, TipoTitulo.filme, 'Família'),
    Recomendacao('A Fantástica Fábrica de Chocolate', 2005, TipoTitulo.filme, 'Família'),
  ],
  'Esporte': [
    Recomendacao('Ford vs Ferrari', 2019, TipoTitulo.filme, 'Esporte'),
    Recomendacao('Rocky: Um Lutador', 1976, TipoTitulo.filme, 'Esporte'),
    Recomendacao('Moneyball', 2011, TipoTitulo.filme, 'Esporte'),
    Recomendacao('Drive to Survive', 2019, TipoTitulo.serie, 'Esporte'),
  ],
  'Infantil': [
    Recomendacao('Bluey', 2018, TipoTitulo.serie, 'Infantil'),
    Recomendacao('Procurando Nemo', 2003, TipoTitulo.filme, 'Infantil'),
    Recomendacao('Toy Story', 1995, TipoTitulo.filme, 'Infantil'),
    Recomendacao('Pocoyo', 2005, TipoTitulo.serie, 'Infantil'),
  ],
  'Reality show': [
    Recomendacao('Queer Eye', 2018, TipoTitulo.serie, 'Reality show'),
    Recomendacao('Love Is Blind', 2020, TipoTitulo.serie, 'Reality show'),
    Recomendacao('The Great British Bake Off', 2010, TipoTitulo.serie, 'Reality show'),
    Recomendacao('Survivor', 2000, TipoTitulo.serie, 'Reality show'),
  ],
};

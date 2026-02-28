#import "@preview/basic-resume:0.2.9": *

// Put your personal information here, replacing mine
#let name = "Michele De Cillis"
#let location = "Milan, IT"
#let email = "work@demic.dev"
#let github = "github.com/demic-dev"
#let linkedin = "linkedin.com/in/michele-decillis"
// #let phone = "+1 (xxx) xxx-xxxx"
#let personal-site = "demic.dev"

#show: resume.with(
  author: name,
  // All the lines below are optional.
  // For example, if you want to to hide your phone number:
  // feel free to comment those lines out and they will not show.
  location: location,
  email: email,
  github: github,
  linkedin: linkedin,
  // phone: phone,
  personal-site: personal-site,
  accent-color: "#26428b",
  font: "New Computer Modern",
  paper: "a4",
  author-position: left,
  personal-info-position: left,
)

/*
 * Lines that start with == are formatted into section headings
 * You can use the specific formatting functions if needed
 * The following formatting functions are listed below
 * #edu(dates: "", degree: "", gpa: "", institution: "", location: "")
 * #work(company: "", dates: "", location: "", title: "")
 * #project(dates: "", name: "", role: "", url: "")
 * #extracurriculars(activity: "", dates: "")
 * There are also the following generic functions that don't apply any formatting
 * #generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "")
 * #generic-one-by-two(left: "", right: "")
 */
== Education

#edu(
  institution: "Università degli Studi di Milano",
  location: "Milan, IT",
  dates: dates-helper(start-date: "Sep 2022", end-date: "Apr 2026"),
  degree: "Bachelor's of Science, Computer Science",
  consistent: true,
)
- Ranked in the top 25% of students in the faculty
- Relevant Coursework: Data Structures, Algebra, Calculus, Physics, Programming

#edu(
  institution: "Université Paris-Saclay",
  location: "Paris, FR",
  dates: dates-helper(start-date: "Sep 2023", end-date: "June 2024"),
  degree: "Erasmus+ Exchange",
  consistent: true,
)

- Relevant Coursework: Linear Programming, Machine Learning, Natural Language Processing, Bioinformatics
- Successfully completed all courses in a new language (French)
- Developed cross-cultural collaboration skills in multinational academic teams

== Work Experience

#work(
  title: "Research Intern",
  location: "Copenhagen, DK",
  company: "IT University of Copenhagen",
  dates: dates-helper(start-date: "Sep 2025", end-date: "Dec 2025"),
)
- Working with large networks from Reddit to identify echo chambers and their dynamics
- Conducting network analysis through Laplacians and Spectral Analysis

#work(
  title: "Co-Founder",
  location: "Remote",
  company: "Polyneta",
  dates: dates-helper(start-date: "Apr 2025", end-date: "Dec 2025"),
)
- Conducted market research and managed communications with users, clients, and partners
- Rapidly developed prototypes to gather user feedback

#work(
  title: "Front-End Engineer",
  location: "Milan, IT",
  company: "Pane&Design s.r.l.",
  dates: dates-helper(start-date: "Sep 2025", end-date: "Dec 2025"),
)
- Developed and optimized high-traffic websites
- Integrated microservices into large codebases

#work(
  title: "Full Stack Engineer",
  location: "Bari, IT",
  company: "Online Impresa s.r.l.",
  dates: dates-helper(start-date: "Jul 2020", end-date: "Sep 2021"),
)
- Designed and built progressive web applications and mobile solutions for SMEs
- Automated deployment pipeline, reducing publishing time from 45 to 10 minutes

== Extracurricular Activities

#extracurriculars(
  activity: "Silicon Valley Study Tour",
  dates: "Aug 2025",
)
- Visited top tech companies and universities in Silicon Valley, hosted by industry experts

#extracurriculars(
  activity: "Won University Startup Challenge",
  dates: "May 2025",
)
- Won a hackathon among all universities in Milan, competing against 400 participants
- Awarded incubation of Polyneta at Fondazione UNIMI

#extracurriculars(
  activity: "Open Source Contributor",
  dates: "present",
)
- #link("https://github.com/pixelfed/pixelfed-rn/pulls?q=author%3Ademic-dev")[Contributed] with bug fixes to an open-source federated social media platform

== Projects

#project(
  name: "ALS Biomarker Identification",
  dates: "May 2024",
  url: "github.com/demic-dev/als-biomarker-identification-project",
  // url: [#link(
  //   "https://github.com/demic-dev/als-biomarker-identification-project",
  // )[GitHub]],
)
- Developed a computational pipeline to analyze RNA-seq data from ALS patients using Python, `scikit-learn`, and `pandas`
- Implemented statistical methods to identify differentially expressed genes that could serve as potential biomarkers

== Skills
- *Technologies*: Git, Nix, Docker, Linux
- *Programming Languages*: Python, Typescript, Go, Rust, SQL, Bash scripting
- *Spoken Languages*: *Italian* (native), *English* (C1), *French* (B1), *Spanish* (A2)

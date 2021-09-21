FROM debian:bullseye as base

ENV DEBIAN_FRONTEND=noninteractive


#* update apt and install R
RUN apt update -qq
RUN apt install -y r-base r-base-dev r-cran-devtools

#* Install other dependencies
RUN apt install -y default-jdk default-jre libxml2-dev libcurl4-openssl-dev libssl-dev libfontconfig1-dev
RUN R CMD javareconf

# Install remaining packages from source
COPY ./requirements.R .
RUN Rscript requirements.R

CMD [ "/bin/bash" ]

FROM base as build

RUN R -e "devtools::install_github('OHDSI/Achilles')"
RUN R -e "devtools::install_github('OHDSI/DataQualityDashboard')"
RUN R -e "devtools::install_github('OHDSI/CohortDiagnostics')"

FROM r-base as deploy

COPY --from=build /usr/local/lib/R/site-library/ /usr/local/lib/R/site-library/

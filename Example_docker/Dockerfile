FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c release -o out

FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY ./out .
ENTRYPOINT ["dotnet", "samplewebapp.dll"]


# dotnet publish -c Release -o out
# docker build -t samplewebapp .


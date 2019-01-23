//
//  LandingPageController.swift
//  App
//
//  Created by Til Blechschmidt on 23.01.19.
//

import Vapor

/// Shows how to use this thing
final class LandingPageController {
    private static let landingPageHTML: String = """
    <html>
        <head>
          <meta charset="UTF-8">
          <title>Super Awesome Mensa Bot</title>
          <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500">
          <style>
            body, html {
              width: 100%;
              height: 100%;
              background-color: #263238;
              color: white;
              font-family: "Roboto", "Helvetica", "serif";
              margin: 0;
              margin-top: 16px;
            }

            #bot {
              width: 100%;
              text-align: center;
              font-size: 3em;
            }

            #title {
              width: 100%;
              text-align: center;
              font-size: 3em;
              margin-bottom: 0.5em;
            }

            #buttons {
              margin: 0 auto;
              width: 100%;
            }

            #instructions {
              min-width: 50vw;
              width: 90vw;
              max-width: 600px;
              margin: 0 auto;
            }

            #instructions > span {
              margin-top: 1em;
              width: 100%;
              text-align: center;
              display: block;
            }

            code {
              background-color: black;
              padding: 8px;
              border-radius: 5px;
              width: 100%;
              display: block;
              text-align: center;
            }

            #link {
              color: white;
              text-decoration: none;
            }

            h4 {
              width: 100%;
              text-align: center;
            }

            #install-links {
              margin-bottom: 5em;
            }

            #install-links > a {
              display: block;
              text-align: center;
              color: white;
            }

            tspan {
              font-size: 2.5em;
            }

            #venn-diagram > h4 {
              margin-bottom: -40px;
            }

            #venn-diagram, #instructions {
              transition-property: opacity;
              transition-duration: 500ms;
              transition-timing-function: ease-in-out;
            }

            .hidden {
              opacity: 0;
            }

            #venn-diagram > svg {
              max-width: 500px;
              display: block;
              margin: auto;
            }

            path {
              transition-property: fill-opacity, fill;
              transition-duration: 250ms;
              transition-timing-function: ease-in-out;
            }

            #venn-sets-A > path {
              fill-opacity: 0.25;
              fill: rgb(31, 110, 50);
            }

            #venn-sets-B > path {
              fill-opacity: 0.25;
              fill: rgb(255, 127, 14);
            }

            #venn-sets-A_B > path {
              fill-opacity: 1;
              fill: rgb(100, 100, 0);
            }

            #venn-sets-A:hover path {
              fill-opacity: 1;
            }

            #venn-sets-A_B:hover path {
              fill: rgb(250, 200, 0);
            }

            #venn-sets-B:hover path {
              fill-opacity: 0.75;
            }
          </style>
        </head>
        <body>
          <div>
            <div id="bot">🤖</div>
            <div id="title">Mensa Bot</div>
          </div>
          <div id="venn-diagram">
            <h4>Select your diet</h4>
            <svg viewBox="0 0 480 384">
              <g id="venn-sets-A">
                <path d="M 152.63954712739877 192
                         m -137.63954712739877 0
                         a 137.63954712739877 137.63954712739877 0 1 0 275.27909425479754 0
                         a 137.63954712739877 137.63954712739877 0 1 0 -275.27909425479754 0"></path>
                <text text-anchor="middle" dy=".35em" x="102" y="192" style="fill: rgb(31, 119, 180);">
                  <tspan x="102" y="192" dy="0.35em">🥦</tspan>
                </text>
              </g>
              <g id="venn-sets-B">
                <path d="M 327.36045287260123 192
                         m -137.63954712739877 0
                         a 137.63954712739877 137.63954712739877 0 1 0 275.27909425479754 0
                         a 137.63954712739877 137.63954712739877 0 1 0 -275.27909425479754 0"></path>
                <text text-anchor="middle" dy=".35em" x="377" y="192" style="fill: rgb(255, 127, 14);">
                  <tspan x="377" y="192" dy="0.35em">🍖</tspan>
                </text>
              </g>
              <g id="venn-sets-A_B">
                <path d="M 240 298.3616293939193
                         A 137.63954712739877 137.63954712739877 0 0 1 240 85.63837060608067
                         A 137.63954712739877 137.63954712739877 0 0 1 240 298.3616293939193"></path>
                <text text-anchor="middle" dy=".35em" x="239" y="191" style="fill: rgb(68, 68, 68);">
                  <tspan x="239" y="191" dy="0.35em">🥪</tspan>
                </text>
              </g>
            </svg>
          </div>

          <div id="instructions" class="hidden">
            <h4>Calendar Subscription Link</h4>
            <code><a id="link" href="https://mensabot.blechschmidt.de/meals.ics">https://mensabot.blechschmidt.de/meals.ics</a></code>
            <h4>How to install</h4>
            <div id="install-links">
              <a target="_blank" rel="noopener noreferrer" href="https://www.imore.com/how-subscribe-calendars-your-iphone-or-ipad">iOS</a>
              <a target="_blank" rel="noopener noreferrer" href="https://support.apple.com/guide/calendar/subscribe-to-calendars-icl1022/mac">macOS</a>
              <a target="_blank" rel="noopener noreferrer" href="http://www.lmgtfy.com/?s=b&q=how+to+subscribe+to+ics+calendar+in+outlook">Windows / Outlook</a>
              <a target="_blank" rel="noopener noreferrer" href="https://support.google.com/calendar/answer/37100?hl=en&co=GENIE.Platform%3DDesktop&oco=1">Google Calendar / Android</a>
            </div>
          </div>

          <script>
            function registerClickListener(id, queryParameter) {
              document.getElementById(id).addEventListener('click', function () {
              showInstructions(queryParameter);
            });
            }

            function showInstructions(queryParameter) {
              document.getElementById('venn-diagram').className = "hidden";

              var link = document.getElementById('link');
              link.href = link.href + queryParameter;
              link.innerHTML = link.href;

              setTimeout(function () {
                document.getElementById('venn-diagram').style.display = 'none';
                document.getElementById('instructions').className = "";
              }, 500);
            }

            registerClickListener('venn-sets-A', '?filterVegetarian=1');
            registerClickListener('venn-sets-A_B');
            registerClickListener('venn-sets-B', '?filterVegetarian=0');
          </script>
        </body>
    </html>
    """

    func index(_ req: Request) throws -> Response {
        return req.makeResponse(http: HTTPResponse.init(status: .ok, version: .init(major: 1, minor: 1), headers: ["Content-Type": "text/html"], body: LandingPageController.landingPageHTML))
    }
}

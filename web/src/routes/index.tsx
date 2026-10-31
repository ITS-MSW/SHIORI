import { createFileRoute } from "@tanstack/react-router";
import {
  AppWindow,
  Code2,
  Command,
  Focus,
  ListChecks,
  MousePointer2,
  Palette,
  PanelRight,
  Search,
} from "lucide-react";
import { Button } from "../components/Button";
import { Title } from "../components/Title";
import { Description } from "../components/Description";
import { NoteDeck } from "../components/NoteDeck";

export const Route = createFileRoute("/")({ component: Home });

const features = [
  [PanelRight, "Notes at your screen’s edge"],
  [MousePointer2, "A little hover. Everything in reach."],
  [ListChecks, "Markdown & clickable checklists"],
  [Palette, "Your colors, your handwriting"],
  [Search, "Find a thought with Quick Search"],
  [AppWindow, "Notes that follow your apps"],
  [Focus, "One note. A little more focus."],
  [Command, "Made for your Mac. Free & open source."],
] as const;

// Enable once the latest published stable release contains SHIORI.dmg.
const downloadAvailable = false;
const downloadUrl = "https://github.com/ITS-MSW/SHIORI/releases/latest/download/SHIORI.dmg";

function Home() {
  const downloadContent = (
    <>
      <svg width="18" height="21" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M17.1 12.6c0-2.4 2-3.5 2.1-3.6-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.2-2.7.8-3.4.8-.7 0-1.8-.8-2.9-.8-1.5 0-3 .9-3.8 2.2-1.6 2.7-.4 6.8 1.1 9 .8 1.1 1.6 2.2 2.8 2.1 1.1 0 1.6-.7 3-.7 1.3 0 1.7.7 2.9.7 1.2 0 2-1.1 2.7-2.2.9-1.2 1.3-2.5 1.3-2.6-.1 0-2.4-.9-2.4-3.1ZM14.9 5.7c.6-.8 1.1-1.9 1-3-.9.1-2 .7-2.7 1.4-.6.7-1.2 1.8-1.1 2.9 1 .1 2.1-.5 2.8-1.3Z" />
      </svg>
      Download for Mac
    </>
  );
  return (
    <main className="landing">
      <div className="page-content">
        <section className="hero" aria-labelledby="hero-title">
          <div className="brand">
            <img src="/favicon.svg" width="36" height="36" alt="" />
            <span>SHIORI</span>
          </div>
          <Title id="hero-title">
            Your thoughts,
            <br />
            within reach.
          </Title>
          <Description>
            A home for your notes, ideas and little reminders.
            <br className="desktop-break" /> At the edge of your screen, a hover
            away.
          </Description>
          <div className="hero-actions">
            {downloadAvailable ? (
              <Button href={downloadUrl} variant="primary">{downloadContent}</Button>
            ) : (
              <Button disabled>{downloadContent}</Button>
            )}
            <Button href="https://github.com/ITS-MSW/SHIORI">
              <Code2 size={17} />
              Get Code
            </Button>
          </div>
          <ul className="features">
            {features.map(([Icon, text]) => (
              <li key={text}>
                <Icon size={14} strokeWidth={1.6} />
                <span>{text}</span>
              </li>
            ))}
          </ul>
        </section>
        <footer>
          <span>
            Version 1.0.0{" "}
            <span className="footer-platform">for macOS 14 or later.</span>
          </span>
          <span>
            Made By <a href="https://x.com/ITS_MSW">MSW</a>
          </span>
        </footer>
      </div>
      <NoteDeck />
    </main>
  );
}

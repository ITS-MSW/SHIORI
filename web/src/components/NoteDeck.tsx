import { useEffect, useRef, useState } from "react";
import type { CSSProperties } from "react";
import { ArrowRight, Pin } from "lucide-react";

const notes = [
  { title: "SHIORI", color: "#fe9d7c" },
  { title: "TODO", color: "#a8e5cf" },
  { title: "A little reminder", color: "#b88bd9" },
];

export function NoteDeck() {
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState<number | null>(null);
  const closeTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const trigger = useRef<HTMLButtonElement>(null);
  const cancelClose = () => {
    if (closeTimer.current) clearTimeout(closeTimer.current);
  };
  const reveal = () => {
    cancelClose();
    setOpen(true);
  };
  const close = () => {
    setOpen(false);
    setActive(null);
  };
  useEffect(
    () => () => {
      if (closeTimer.current) clearTimeout(closeTimer.current);
    },
    [],
  );

  return (
    <aside
      className={`note-dock ${open ? "is-open" : ""}`}
      aria-label="Try SHIORI sticky notes"
      onPointerEnter={reveal}
      onPointerMove={(event) => {
        if (!open) return;
        const bounds = event.currentTarget.getBoundingClientRect();
        // Native DockView gives the edge slots priority over the lifted sheet.
        if (event.clientX >= bounds.right - 40) {
          const index = Math.min(
            2,
            Math.floor((event.clientY - bounds.top) / 74),
          );
          if (index >= 0) setActive(index);
        }
      }}
      onPointerLeave={(event) => {
        if (event.currentTarget.contains(document.activeElement)) return;
        cancelClose();
        closeTimer.current = setTimeout(close, 220);
      }}
      onFocus={reveal}
      onBlur={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget)) close();
      }}
      onKeyDown={(event) => {
        if (event.key === "Escape") {
          trigger.current?.focus();
          close();
        }
      }}
    >
      <button
        ref={trigger}
        className="dock-trigger"
        aria-label="Preview sticky notes"
        aria-expanded={open}
        aria-controls="note-cards"
        onClick={reveal}
      >
        {notes.map((note) => (
          <span key={note.title} style={{ background: note.color }} />
        ))}
      </button>
      <span className="dock-hint" aria-hidden="true">
        Hover to peek <ArrowRight size={14} />
      </span>
      <div id="note-cards" className="note-cards" inert={!open}>
        {notes.map((note, index) => (
          <article
            key={note.title}
            className={`note ${active === index ? "is-active" : ""}`}
            style={
              {
                "--note-color": note.color,
                "--index": index,
                "--tilt": `${-(0.8 + index * 0.35)}deg`,
              } as CSSProperties
            }
            onPointerEnter={() => {
              reveal();
              setActive(index);
            }}
            onFocus={() => setActive(index)}
          >
            <button
              className="note-tab"
              aria-label={`Preview ${note.title}`}
              aria-expanded={active === index}
              onClick={() => setActive(index)}
            >
              {note.title}
            </button>
            <div className="note-content" inert={active !== index}>
              <div className="note-heading">
                <h2>{note.title}</h2>
                <Pin size={15} />
              </div>
              <p className="note-date">29/10/2026, 09:41</p>
              {index === 0 && (
                <>
                  <p>
                    Your next idea deserves
                    <br />a place to stay.
                  </p>
                  <a href="https://github.com/ITS-MSW/SHIORI">
                    Make room for it <ArrowRight size={14} />
                  </a>
                </>
              )}
              {index === 1 && (
                <div className="checklist">
                  {[
                    "Star the SHIORI repo",
                    "Capture a little idea",
                    "Make something lovely",
                  ].map((item, i) => (
                    <label key={item}>
                      <input type="checkbox" defaultChecked={i === 1} />
                      <span>{item}</span>
                    </label>
                  ))}
                </div>
              )}
              {index === 2 && (
                <>
                  <p>
                    You don’t have to hold
                    <br />
                    everything in your head.
                  </p>
                  <p className="note-signoff">Leave a little note. ♡</p>
                </>
              )}
            </div>
          </article>
        ))}
      </div>
    </aside>
  );
}

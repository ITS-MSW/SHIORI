import type { ComponentProps } from "react";

export function Description({ className = "", ...props }: ComponentProps<"p">) {
  return <p className={`description ${className}`} {...props} />;
}

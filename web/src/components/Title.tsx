import type { ComponentProps } from "react";

export function Title({ className = "", ...props }: ComponentProps<"h1">) {
  return <h1 className={`title ${className}`} {...props} />;
}

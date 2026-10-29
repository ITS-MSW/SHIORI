import type { ComponentProps } from "react";

type Props =
  | ({ href: string } & ComponentProps<"a">)
  | ({ href?: never } & ComponentProps<"button">);

export function Button(props: Props) {
  if (props.href !== undefined) {
    const { className = "", ...rest } = props as ComponentProps<"a">;
    return <a className={`button button-secondary ${className}`} {...rest} />;
  }
  const { className = "", ...rest } = props as ComponentProps<"button">;
  return (
    <button
      type="button"
      className={`button button-primary ${className}`}
      {...rest}
    />
  );
}

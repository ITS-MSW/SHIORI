import type { ComponentProps } from "react";

type Props = { variant?: "primary" | "secondary" } & (
  | ({ href: string } & ComponentProps<"a">)
  | ({ href?: never } & ComponentProps<"button">)
);

export function Button(props: Props) {
  if (props.href !== undefined) {
    const { className = "", variant = "secondary", ...rest } = props;
    return <a className={`button button-${variant} ${className}`} {...rest} />;
  }
  const { className = "", variant = "primary", ...rest } = props;
  return (
    <button
      type="button"
      className={`button button-${variant} ${className}`}
      {...rest}
    />
  );
}

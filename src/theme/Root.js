import React from 'react';
import CookieConsent from 'react-cookie-consent';

export default function Root({ children }) {
  return (
    <>
      {children}
      <CookieConsent
        location="bottom"
        cookieName="docusapiensCookieConsent"
        expires={365}
        buttonText="Accept"
        declineButtonText="Decline"
        enableDeclineButton
        flipButtons
        containerClasses="cookie-consent-banner"
        contentClasses="cookie-consent-content"
        buttonClasses="cookie-consent-accept"
        declineButtonClasses="cookie-consent-decline"
        buttonWrapperClasses="cookie-consent-buttons"
        disableStyles
        sameSite="lax"
      >
        This website uses cookies to enhance your experience. By continuing to
        use this site, you agree to our{' '}
        <a
          href="https://docusapiens.ai/terms/"
          target="_blank"
          rel="noopener noreferrer"
          className="cookie-consent-link"
        >
          Terms of Service
        </a>{' '}
        and{' '}
        <a
          href="https://docusapiens.ai/privacy/"
          target="_blank"
          rel="noopener noreferrer"
          className="cookie-consent-link"
        >
          Privacy Policy
        </a>
        .
      </CookieConsent>
    </>
  );
}

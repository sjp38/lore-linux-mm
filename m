Date: Mon, 29 Dec 2003 10:55:15 -0800
Subject: Re: 2.6.0-mm2
Message-ID: <20031229185515.GB9954@triplehelix.org>
References: <20031229013223.75c531ed.akpm@osdl.org> <1072722682.15739.2.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kORqDWCi7qDJ0mEj"
Content-Disposition: inline
In-Reply-To: <1072722682.15739.2.camel@mentor.gurulabs.com>
From: joshk@triplehelix.org (Joshua Kwan)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dax Kelson <dax@gurulabs.com>
Cc: linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 29, 2003 at 11:31:22AM -0700, Dax Kelson wrote:
> WARNING: /lib/modules/2.6.0-mm2/kernel/drivers/net/pcmcia/axnet_cs.ko nee=
ds unknown symbol CardServices

I guess Andres had missed one...

--- linux-2.6.0/drivers/net/pcmcia/axnet_cs.c~	2003-12-29 10:53:44.00000000=
0 -0800
+++ linux-2.6.0/drivers/net/pcmcia/axnet_cs.c	2003-12-29 10:53:59.000000000=
 -0800
@@ -541,7 +541,7 @@
 	if (link->state & DEV_CONFIG) {
 	    if (link->open)
 		netif_device_detach(dev);
-	    CardServices(ReleaseConfiguration, link->handle);
+	    pcmcia_release_configuration(link->handle);
 	}
 	break;
     case CS_EVENT_PM_RESUME:

--=20
Joshua Kwan

--kORqDWCi7qDJ0mEj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iQIVAwUBP/B4kqOILr94RG8mAQIm9xAAyJGPFbm0RkaybhFcWDvzlIAp/BgYxzhX
2IP3CyXm7346v2pwa0BGK2M7P1cUUmVWUeAGBN+ejUaRZFm+sZXT+qaRMX4UUqha
ibnWwV66pnCC9jt2lkKr/NuS//luYR4zvrgIMQYrHzXkXbAXtyfjSdKPweMg8Sek
2tof904+H32/p/S7WDKnhj+BuewG48gvT3thhwZ7EKeFeTQunZ6hvReFgzyNhOBl
HEsslDC1VbmHHtr2vuMqjuyh85DRX0wfVDirOdDZRtLHOHgd+KdbVcKGTzVBESt9
cUroFjZVg4TDLZqiDnCHCk/+mRVdbhkoA9caeDNeGR15Nvp/TVagcsR/Mzk0Abf2
YfyRQ41Z6cIlBwuoV/GsSfIT52YN58k2nghpqQnlrxCksF4w0ecpY/z8Tv7R/0JT
g9IaIRYxt2WHBB/syBpW50bzj+Wt1qOsfSYE1Mj6y2oR2/49wjbPKaNLFI1cvjAe
WJucKovXMhcz+UzJBfiRgQXNHHnz9bp9ZGn3a/0e23/0WHmCTlPzBKvEplQH47WO
S4aFEtd7NA6qBjlMqLZrVyANLKB52jcze2E8VaiZPbsrHFpc+gBfRbdrl1K7gMJ6
zUpTL3t0gKSdVJRbk7nnLsQRgPSL+YY3kkdT0F4M2aNmulq1+FXUx9NnzXD9W1EW
VuoA6bL8eIA=
=L5lL
-----END PGP SIGNATURE-----

--kORqDWCi7qDJ0mEj--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

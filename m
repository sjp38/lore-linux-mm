Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5906B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:48:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so320283938pgd.7
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:48:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id g126si42861pgc.83.2017.01.26.09.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:48:56 -0800 (PST)
Date: Thu, 26 Jan 2017 18:48:50 +0100
From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [PATCH] fixup! mm, fs: reduce fault, page_mkwrite, and
 pfn_mkwrite to take only vmf
Message-ID: <20170126174850.yukhiaclt6gxbfac@earth>
References: <20170125223558.1451224-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ae5crblg2o7xpqat"
Content-Disposition: inline
In-Reply-To: <20170125223558.1451224-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, David Airlie <airlied@linux.ie>, Lucas Stach <l.stach@pengutronix.de>, Christian Gmeiner <christian.gmeiner@gmail.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Chris Wilson <chris@chris-wilson.co.uk>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, etnaviv@lists.freedesktop.org


--ae5crblg2o7xpqat
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jan 25, 2017 at 11:35:05PM +0100, Arnd Bergmann wrote:
> I ran into a couple of build problems on ARM, these are the changes that
> should be folded into the original patch that changed all the ->fault()
> prototypes
>=20
> Fixes: mmtom ("mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to tak=
e only vmf")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-By: Sebastian Reichel <sre@kernel.org>

-- Sebastian

--ae5crblg2o7xpqat
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAliKNn8ACgkQ2O7X88g7
+pocTBAAmh4+NZI6gzaz/4ENPv7croz6eX4dtFloLS0dWhJMxu/aiatrzEkDWloQ
z5tcz2ivSA/zGgayNIq/wXIUUIC5Owv5Sk3SMlLObsdLU1vbO7bZM1g3MWPTDDlj
inVUIRhpITIVH3HviIi/uGUYBpC7oFwQ1H2agHwYZDw8VNJlDImaStLwj6OD+q4L
zirOsiVNKXnVMnzJUd+FT8X7iJjZARtkmPEeAGD+oM5A5a/K6YaIxk3AnY5ZcotB
nr/ywFkAnR1IHcYZ0PFMOpotwDHnyVT8TIG7vHPt5ScgAA0WPgw/basGcNcLzEp9
bqWj8UiSWNPEPgpGyy2EtUTTe5KGfQZMPSkBbOYi+utCi3Nmkt2hayY9cgSanv4F
8r2cauquf4Fg2Ej5exkO6nR0mWmPjH+3smyMqzljxsf728CYBv9m/bwlXJXI5/Oh
OPZEu7QmRFzgWnIfYUAXNZu5s7RdLPP4DsnI7hU2msvoTbfi2h4y1xsxuy3f19ve
XfNo0Zi/d/MWm1Y4HPTGVEGXos4jzwMW5x/bZZl6weZU/Y/VL3RiZ3lIYGPQ3s60
2RioQ/+7TPmli/kgdyy2JhKPOYpGGkBUi2NB3GE6sBeI12+sCK3Xy5RlZz+xaaUX
kb/F++HQCAKxJjStuiGITjd/eXXFpHe+VMCJLTqa0LZhoT/6Kn8=
=c4Ep
-----END PGP SIGNATURE-----

--ae5crblg2o7xpqat--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

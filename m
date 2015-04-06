Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id D89426B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:40:04 -0400 (EDT)
Received: by ierf6 with SMTP id f6so29342466ier.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:40:04 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id b3si4517938igx.41.2015.04.06.12.40.04
        for <linux-mm@kvack.org>;
        Mon, 06 Apr 2015 12:40:04 -0700 (PDT)
Date: Mon, 6 Apr 2015 21:39:32 +0200
From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [PATCH 16/25] include/linux: Use bool function return values of
 true/false not 1/0
Message-ID: <20150406193931.GA987@earth>
References: <cover.1427759009.git.joe@perches.com>
 <5edb9453646625a405ef0a642bec0819c0e6c2eb.1427759009.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Content-Disposition: inline
In-Reply-To: <5edb9453646625a405ef0a642bec0819c0e6c2eb.1427759009.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Jason Wessel <jason.wessel@windriver.com>, Samuel Ortiz <sameo@linux.intel.com>, Lee Jones <lee.jones@linaro.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Michael Buesch <m@bues.ch>, linux-ide@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-mm@kvack.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Mon, Mar 30, 2015 at 04:46:14PM -0700, Joe Perches wrote:
> Use the normal return values for bool functions

Acked-By: Sebastian Reichel <sre@kernel.org>

-- Sebastian

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJVIuDwAAoJENju1/PIO/qaqk4P/1T77yAjH3OWYaxSSH8mrwQs
dYFbDr7X97o2lePKrZe/1fFTpO24u+tOp6v27f7NkRDiw+A7k1ZkHLbGKsCZ4CFc
9vbR4vE1sPPlbLZTgkHzvGYlTAjdMEa5elbDMRthh+vvqI7Q/yIX+H5Ln+Txtk7u
MPpv6JqW9efxZgxOUnSaFa8Xlj2VbAKqzQsMYICTRjYezmPV5gdd165KMCV41PqC
vdiF6HxjaB+lyW7vhWzCA660MJGpqOelRk1vYjR2uoNFbVQnEv1Z0NGBrr1xEtW2
CWdeee+kj3JtAFFTMNgZZpGzbdZ0Ka4tg8Yk2Sxo3tsOO+l7D0s+S6qlIaCqOmd9
hse/43XhxQbxl5fW9Oriu76sDYYxccdk7syqGf/2rsakVk3StJprfLrhyOnYkx8C
UCVeWH/JNiH4ngov8Iz4hIUMpXrmo9gUSYK3Z7qX5Xg6F9hTLIxZnJAh3ShNyOYr
lSf3K/SsHigNYtm5+YwFzaYqIaSnBfdeiMuStK6sT5+cDDUAeQ2ilt9/tCZbPfvC
DemPzS371iq80QPzDDmva74L3TKYUJOodOY/rBCDJYtMwLdH3UotDHPjKFBQ3nnS
h64nLHgmHR0CRQtqp/Sz+ePY8Cjs69OLxhHi6RQyijZjKc2Uarxkfcs6DcMdn1WL
TbT3PZSZMM547HAFeN4v
=yK9g
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

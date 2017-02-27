Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B10E6B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:49:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 73so45885933wrb.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:49:21 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id x81si13782956wmb.43.2017.02.27.06.49.20
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 06:49:20 -0800 (PST)
Date: Mon, 27 Feb 2017 15:49:19 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 4/8] drm/sun4i: Grab reserved memory region
Message-ID: <20170227144919.pijmvi3yptvxlbkx@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <cf185f6de351837a9a29c123ca801682c983b83d.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="drwddbbdvfj3blu7"
Content-Disposition: inline
In-Reply-To: <cf185f6de351837a9a29c123ca801682c983b83d.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--drwddbbdvfj3blu7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 09, 2017 at 05:39:18PM +0100, Maxime Ripard wrote:
> Allow to provide an optional memory region to allocate from for our DRM
> driver.
>=20
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Fixed the conflicts and applied.
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--drwddbbdvfj3blu7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYtDxrAAoJEBx+YmzsjxAgCKgP/j2zjI1Va7uaSMFU/DjawVpR
m2Acc1QiVTi0LxG5Q6/iuq6EO//3FTxT7QzlQoE3iRstRRlWZ2u2qjtSCL/gW8cj
sPwxAzJaYfrMwzTVBPxbUeNyihDTmR263WCZXZfw7QrL0n2rdZ/GJoxQOgzicxOC
taOo0yOyTiEjqIPdNiWVrGZiErIaK/8CdW8k3msAqI5YZIrzJ0IWgVaIE/7Qn8vx
wpY7LHYyhrH5ogJUpkqhOtEXaSFLjn4zdAy0HwACYmMtyoi8JJvHH3vK2YArvJrX
UUDqGgc3IpzrXaf8iPhXnSkBFQfoqX7JL/buE7VeVh4HW78y8LZkc2jXCh7HLBAn
xj/9muedm07odljkknHT31LZ5uBL4hclxLoXRryLRo6lyjvbFP0wD0DkxQ42rfjN
A+qiDAy2QwhipXzZaMdl9OECsQWb/CG79lG9MuLcI382zakxHBFv6OhyELGapb8/
0ncc/D1Fu+Y49BQ0T6Riw6vo52mN7aUfM0/P1NtyMNlUiuM/l4zuX9dK5PDnMDPK
36PuN5mFjZ0VvG8zB47cRN7NJNvEhYk2AZ+XrJuWa7cuGBo0ImTYmt51sg2RqGVO
7w6oW47JljCmLjzkM+8ZFE9Ru+FR9T2BB/iHZyTxPYKTMkKZ9ZeaUdaNVWQyQnCv
2y0bPSf7gqQh72zE2UvH
=SJQV
-----END PGP SIGNATURE-----

--drwddbbdvfj3blu7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

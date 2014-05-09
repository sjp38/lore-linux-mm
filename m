Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E15F16B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:46:57 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id w10so3792685pde.19
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:46:57 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id se7si2470283pbb.10.2014.05.09.08.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:46:57 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id w10so3792673pde.19
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:46:56 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 3/3] CMA: always treat free cma pages as non-free on watermark checking
In-Reply-To: <1399509144-8898-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-4-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 09 May 2014 08:46:50 -0700
Message-ID: <xa1t1tw3x8d1.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 07 2014, Joonsoo Kim wrote:
> commit d95ea5d1('cma: fix watermark checking') introduces ALLOC_CMA flag
> for alloc flag and treats free cma pages as free pages if this flag is
> passed to watermark checking. Intention of that patch is that movable page
> allocation can be be handled from cma reserved region without starting
> kswapd. Now, previous patch changes the behaviour of allocator that
> movable allocation uses the page on cma reserved region aggressively,
> so this watermark hack isn't needed anymore. Therefore remove it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>


--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTbPhqAAoJECBgQBJQdR/0W00P/2lA4due77ZgrKd3+b1G+hZW
54DbdgQdTTJZQJZGeCtCKx/v9O4nY6suKmeGQXpleMog4BGEUa/+UMVM8ZGZSwYv
DZjqTM4l/lwuK4fU0jEdSKwBmpYL9PnvtLhduY6iEuqW4zxqqZFo3Hkp5fdi++eh
XSUl2TTD/p97HqIJrRCjNsBwk67iQ06uH1Xn3BPdPFem4sXiyyuUbWwv2+kwcfJk
OICFmLXgMw4SDybGcADT7KTHp94BpDmqIOK4fu+hOGoGYzEQ0ECPZDnVgILRAbc/
mzecpMZWKYdsr/QXboAO7BU9V23x1DedJsJs87/Vq6MjB0PRUIAhUA4q52aI4Q9p
i03xO9ulah32J38Xium37xXmTj1unKd2V92q+nyJWd8tMTyAwiTwFZycU7WoeT+7
oSUzVXfqW/Lq9idLFyALyRjs7iq0ofaeW1xaQs+qeVNK/Pq6X0NtEsB8n2AEjZuh
Upy2h873IHhpT/YM4ZmxkL0VihqZOd6ofojgGXAj3Z+M9z8iQMEYeV9SwxM0URy0
d3IFE1fR0zWWZGJeWikKuv+iQk1lqIpD7fyEcqHJER2F8SBirtKFtIxbNec1tXEU
vbPOogilTy8lzdRq9dlft/iF93ogOcGAzGSrgtJshYlMdsH7yWWN0d/KCYjjuF7T
Q0ACZTmO0v/QIsNfEU4y
=BUaR
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

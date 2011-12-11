Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8C75E6B0073
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 17:46:17 -0500 (EST)
Date: Mon, 12 Dec 2011 09:45:59 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 6/8] common: dma-mapping: change alloc/free_coherent
 method to more generic alloc/free_attrs
Message-Id: <20111212094559.e4af7c0ab6633de400487fde@canb.auug.org.au>
In-Reply-To: <1323448798-18184-7-git-send-email-m.szyprowski@samsung.com>
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
	<1323448798-18184-7-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__12_Dec_2011_09_45_59_+1100_WVzuTZ1dmc23zb5p"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

--Signature=_Mon__12_Dec_2011_09_45_59_+1100_WVzuTZ1dmc23zb5p
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marek,

On Fri, 09 Dec 2011 17:39:56 +0100 Marek Szyprowski <m.szyprowski@samsung.c=
om> wrote:
>
> Introduce new alloc/free/mmap methods that take attributes argument.
> alloc/free_coherent can be implemented on top of the new alloc/free
> calls with NULL attributes. dma_alloc_non_coherent can be implemented
> using DMA_ATTR_NONCOHERENT attribute, dma_alloc_writecombine can also
> use separate DMA_ATTR_WRITECOMBINE attribute. This way the drivers will
> get more generic, platform independent way of allocating dma memory
> buffers with specific parameters.
>=20
> One more attribute can be usefull: DMA_ATTR_NOKERNELVADDR. Buffers with
> such attribute will not have valid kernel virtual address. They might be
> usefull for drivers that only exports the DMA buffers to userspace (like
> for example V4L2 or ALSA).
>=20
> mmap method is introduced to let the drivers create a user space mapping
> for a DMA buffer in generic, architecture independent way.
>=20
> TODO: update all dma_map_ops clients for all architectures

To give everyone some chance, you should come up with a transition plan
rather than this "attempt to fix everyone at once" approach.  You could
(for example) just add the new methods now and only remove them in the
following merge window when all the architectures have had a chance to
migrate.

And, in fact, (as I presume you know) this patch just breaks everyone
with no attempt to cope.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__12_Dec_2011_09_45_59_+1100_WVzuTZ1dmc23zb5p
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO5TKnAAoJEECxmPOUX5FEDhYQAIIFT6ARFw14dmermAXdDmoU
2ZoHCPA2xb7XojK7ObZ8rhc0dL3QR29rQ5X16xLPzaCD5nLJ/eUupMUU8fJfkjHh
WMnOhZYIxeTO1Ek93+mbdHWXiaBwBHYIIwfelTkhEDXzZLYwZxcy/1f38fXo2QZO
Xv3PoWy9KDYw+NFArm9lQmJMsIN6wit1+RGv+l5XKvHmbp/I65LO98b2LWGz0Ve7
m9q9JAtA9uThM1/EyyymlZNXxBjbOW8N8lrPBmq+eGAnsd51BbcZfZVH8c1wcdHh
ZQG2XI1V7JrpVjK3N1OcFsrsdyuZPh+AoEjwnMXc+cpzjV1UZQhHLO5UFOoH4ZMv
Asz38rIvPYKLYb9j6F1nBnvI7iN18+Fl1Jj5FpadTskOEPWtOr6vQFRnUbTVbbRO
0MVPEA8OdKdyxdUZfBnm9hIU2TMLeolM8qjaDUTHh68rdZEIcaMczGjjLzjVOeu4
yDc0K/OGX9BkYyuUrA6D73yb0wJrfrahLDnBACFMJHWlU9N6aOBOIsgq4JDb3jZB
kR48QHcBX9mO6Tu0lil3ckuakbX6pXF5xtPbaMTURDvneHQ8t02hL0T2T3tVx47R
JZ8SK5gnxgJUSnK4imCzrLtAwK2qzMJLtCKP8vc7tk0Wy/Z1SiPHtf4YZsbVlEBY
QjKzi1wpQiluTnvuqPgR
=F3zl
-----END PGP SIGNATURE-----

--Signature=_Mon__12_Dec_2011_09_45_59_+1100_WVzuTZ1dmc23zb5p--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

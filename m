Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C45B26B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 14:06:03 -0400 (EDT)
Received: by bkcjm1 with SMTP id jm1so4424334bkc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:06:02 -0700 (PDT)
Message-ID: <1348855547.1556.3.camel@kyv>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Fri, 28 Sep 2012 21:05:47 +0300
In-Reply-To: <CA+55aFyWdxD4Qb9PuPKKx_Ww_khYkWg1s-3QWVUwsTSXSUMG5w@mail.gmail.com>
References: <1340959739.2936.28.camel@lappy>
	 <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
	 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
	 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
	 <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
	 <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>
	 <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
	 <1347202600.5876.7.camel@sbsiddha-ivb> <505068F4.4080309@gmail.com>
	 <50506A6C.30109@gmail.com> <50656733.3040609@gmail.com>
	 <CA+55aFyWdxD4Qb9PuPKKx_Ww_khYkWg1s-3QWVUwsTSXSUMG5w@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-uvK0CBFgSutU0YjZ4GCa"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, suresh.b.siddha@intel.com, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>


--=-uvK0CBFgSutU0YjZ4GCa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-09-28 at 09:44 -0700, Linus Torvalds wrote:
> On Fri, Sep 28, 2012 at 2:00 AM, Sasha Levin <levinsasha928@gmail.com> wr=
ote:
> >
> > Is anyone planning on picking up Linus' patch? This is still not in -ne=
xt even.
>=20
> I was really hoping it would go through the regular channels and come
> back to me that way, since I can't really test it, and it's bigger
> than the trivial obvious one-liners that I'm happy to commit.

Hi Linus,

I am not the maintainer, but please, go ahead an push your fix. I do not
have time to test it myself and it does not look like anyone else in the
small mtd community does.

--=20
Best Regards,
Artem Bityutskiy

--=-uvK0CBFgSutU0YjZ4GCa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQZeb7AAoJECmIfjd9wqK0yIEQAJPMC14O9L2VXLXAX7aMJVMZ
21CmChmzQA4K9Y4UO6O0UDnCaAwbJbjHyY5xCT7b2UIbbQijU+QWhrsPwbVjnrLH
42rl6Q5CjNdWXQ/KiOFwNDrHYHJcyMIDcyzn2TMbFM3yCMB7+jsrd3Y6hfqbhtMb
CBeMLx58N2go0cWa7ydcRWLYA2febnMGG0tTsCfmHus3FZGt80pa1PJZtwS/1X5s
DEJfbRqROgaNSqOnJjjdMvBuM1EwB0TUphnewqUukqR3K6JnZHb7VcFVcPR3Mx2D
+pX6Smg22zQKoxQ6uHyqTc+d3JMaRUX23wGM5UHv29Yo9kPCCTUaAiYiouIwH7BC
9WQjRXu3aeyOjxfqcgjplul4SNGGALYNF0ESNgzFr5Urj/ChCF4f2F1V1Ch1KZVM
xu47tExfPrEKEe0Omg+w7AhnKl/3aptSm3lrhiMobC6/wcGjRneaGTcsB3Yv4Yc+
eKIyb+wxosjSinb0CtQZktmCgzndrqW1BmoM8+HFTXhPp/YVmhdkuE7tfemNRj0A
hGYX+REE4CAtAPrqegeQYKCsYN7pBX0sANaXIV4eR6RnW/BQUxfqf0+Ehv9weHgf
hNFK0QJ8z07TKlknyW1LgklXYoeavFpEJQd+VzqMrb3tgGwWO8ONCGIB4FRv+xNS
5ijhFyx6m8jzy8I0cWBB
=PzM1
-----END PGP SIGNATURE-----

--=-uvK0CBFgSutU0YjZ4GCa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

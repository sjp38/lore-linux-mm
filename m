Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8DA3F6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 07:06:40 -0400 (EDT)
Date: Thu, 9 Sep 2010 21:06:24 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 08/43] memblock/microblaze: Use new accessors
Message-Id: <20100909210624.713183ed.sfr@canb.auug.org.au>
In-Reply-To: <4C88BD8F.5080208@monstr.eu>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
	<1281071724-28740-9-git-send-email-benh@kernel.crashing.org>
	<4C5BCD41.3040501@monstr.eu>
	<1281135046.2168.40.camel@pasglop>
	<4C88BD8F.5080208@monstr.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__9_Sep_2010_21_06_24_+1000_3GV7i0YsjOJR2V1T"
Sender: owner-linux-mm@kvack.org
To: monstr@monstr.eu
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

--Signature=_Thu__9_Sep_2010_21_06_24_+1000_3GV7i0YsjOJR2V1T
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Michal,

On Thu, 09 Sep 2010 12:57:19 +0200 Michal Simek <monstr@monstr.eu> wrote:
>
> Benjamin Herrenschmidt wrote:
> > On Fri, 2010-08-06 at 10:52 +0200, Michal Simek wrote:
> >> Benjamin Herrenschmidt wrote:
> >>> CC: Michal Simek <monstr@monstr.eu>
> >>> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> >> This patch remove bug which I reported but there is another place whic=
h=20
> >> needs to be changed.
> >>
> >> I am not sure if my patch is correct but at least point you on places=
=20
> >> which is causing compilation errors.
> >>
> >> I tested your memblock branch with this fix and microblaze can boot.
> >=20
> > Ok, that's missing in my initial rename patch. I'll fix it up. Thanks.
> >=20
> > Cheers,
> > Ben.
>=20
> I don't know why but this unfixed old patch is in linux-next today. Not=20
> sure which tree contains it.

It came in via the tip tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__9_Sep_2010_21_06_24_+1000_3GV7i0YsjOJR2V1T
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMiL+wAAoJEDMEi1NhKgbsDcwIAIybFy2fc20CUeAlDh11uDKn
Ns72FQioH6oK2G+3pF3xCADKFRVkF1U3oEz0sw7clNtfUy05H5JUdYRkXjlbM/Df
CgQDDubV5cty8qRq4LAV4jfEWEmFDbnmthUZXSjPcwkEgwhJp3L4+VD/nYwa16GD
i3unmEmBO8T6YoQ8LAup/C6Z8RhLRu+9qRh+QwJh1knK+7U5nKpqDUQbtb6OGvXf
tQPfOrBlRwNNWIbl7zPEYqzEL//so7WfqI2AQkmnZLTV4fHSjLUFKhZyO15hqU7J
iIIeP8emzCnQ5JXqdeQGoewbQqTslIPwicNuByS5+25sdpkmAOCf+mebw3ugLpQ=
=g82Z
-----END PGP SIGNATURE-----

--Signature=_Thu__9_Sep_2010_21_06_24_+1000_3GV7i0YsjOJR2V1T--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Dirk Schoebel <dirk@liji-und-dirk.de>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
Date: Fri, 27 Jul 2007 00:04:38 +0200
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <b14e81f00707260719w63d8ab38jbf2a17a38bd07c1d@mail.gmail.com> <20070726111326.873f7b0a.akpm@linux-foundation.org>
In-Reply-To: <20070726111326.873f7b0a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2470270.ABJPYyX5vq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200707270004.46211.dirk@liji-und-dirk.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ck@vds.kolivas.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Chang <thenewme91@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Eric St-Laurent <ericstl34@sympatico.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Jesper Juhl <jesper.juhl@gmail.com>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

--nextPart2470270.ABJPYyX5vq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I don't really understand the reasons for all those discussions.
As long as you have a maintainer, why don't you just put swap prefetch into=
=20
the kernel, marked experimental, default deactivated so anyone who just=20
make[s] oldconfig (or defaultconfig) won't get it. If anyone finds a good=20
solution for all those cache 'poisoning' problems and problems concerning=20
swapin on workload changes and such swap prefetch can easily taken out agai=
n=20
and no one has to complain and continuing maintaining it.
Actually the same goes for plugshed (having it might have kept Con as a=20
valuable developer).
I am actually waiting for more than 2 years that reiser4 will make it into =
the=20
kernel (sure, marked experimental or even highly experimental) so the=20
patch-journey for every new kernel comes to an end. And most things in-kern=
el=20
will surely be tested more intense so bugs will come up much faster.=20
(Constantly running MM kernels is not really an option since many things in=
=20
there can't be deactivated if they don't work as expected since lots of=20
patches also concern 'vital' parts of the kernel.)

=2E..just 2cents from a happy CK user for it made it possible to watch a mo=
vie=20
while compiling the system - which was impossible with mainline kernel, eve=
n=20
on dual core 2.2 GHz AMD64 with 4G RAM !

Dirk.

--nextPart2470270.ABJPYyX5vq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD8DBQBGqRp+6YYnt7muP7IRArLyAJ91sIZPuxe6co3Swp7LjaCKGsoy5QCg6Hpy
76zfIgZ9L7Iw7avW/ko6GeE=
=CUXM
-----END PGP SIGNATURE-----

--nextPart2470270.ABJPYyX5vq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [PATCH] mm: avoid dirtying shared mappings on mlock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710120257.05960.nickpiggin@yahoo.com.au>
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org>
	 <69AF9B2A-6AA7-4078-B0A2-BE3D4914AEDC@FreeBSD.org>
	 <1192179805.27435.6.camel@twins>
	 <200710120257.05960.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5U/g6opYOoJT2WQRDHyS"
Date: Fri, 12 Oct 2007 12:37:19 +0200
Message-Id: <1192185439.27435.19.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

--=-5U/g6opYOoJT2WQRDHyS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-10-12 at 02:57 +1000, Nick Piggin wrote:
> On Friday 12 October 2007 19:03, Peter Zijlstra wrote:
> > Subject: mm: avoid dirtying shared mappings on mlock
> >
> > Suleiman noticed that shared mappings get dirtied when mlocked.
> > Avoid this by teaching make_pages_present about this case.
> >
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Acked-by: Suleiman Souhlal <suleiman@google.com>
>=20
> Umm, I don't see the other piece of this thread, so I don't
> know what the actual problem was.
>=20
> But I would really rather not do this. If you do this, then you
> now can get random SIGBUSes when you write into the memory if it
> can't allocate blocks or ... (some other filesystem specific
> condition).

I'm not getting this, make_pages_present() only has to ensure all the
pages are read from disk and in memory. How is this different from a
read-scan?

The pages will still be read-only due to dirty tracking, so the first
write will still do page_mkwrite().



--=-5U/g6opYOoJT2WQRDHyS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHD05fXA2jU0ANEf4RAu2gAJ9NtXDA2E6emN+/OJpCt9TPYCcHOgCgkLUz
Nzg60UY4sfss94SPRiG2eYI=
=UOp0
-----END PGP SIGNATURE-----

--=-5U/g6opYOoJT2WQRDHyS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

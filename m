Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8198D6B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 13:05:08 -0400 (EDT)
Received: by pablj1 with SMTP id lj1so64878651pab.10
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 10:05:08 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id uz1si18652041pac.149.2015.03.09.10.05.07
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 10:05:07 -0700 (PDT)
Date: Mon, 9 Mar 2015 13:05:05 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH] Allow compaction of unevictable pages
Message-ID: <20150309170505.GA2290@akamai.com>
References: <1425667287-30841-1-git-send-email-emunson@akamai.com>
 <alpine.DEB.2.10.1503061301500.10330@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503061301500.10330@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 06 Mar 2015, David Rientjes wrote:

> On Fri, 6 Mar 2015, Eric B Munson wrote:
>=20
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 8c0d945..33c81e1 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1056,7 +1056,7 @@ static isolate_migrate_t isolate_migratepages(str=
uct zone *zone,
> >  {
> >  	unsigned long low_pfn, end_pfn;
> >  	struct page *page;
> > -	const isolate_mode_t isolate_mode =3D
> > +	const isolate_mode_t isolate_mode =3D ISOLATE_UNEVICTABLE |
> >  		(cc->mode =3D=3D MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> > =20
> >  	/*
>=20
> I agree that memory compaction should be isolating and migrating=20
> unevictable memory for better results, and we have been running with a=20
> similar patch internally for about a year for the same purpose as you,=20
> higher probability of allocating hugepages.
>=20
> This would be better off removing the notion of ISOLATE_UNEVICTABLE=20
> entirely, however, since CMA and now memory compaction would be using it,=
=20
> so the check in __isolate_lru_page() is no longer necessary.  Has the=20
> added bonus of removing about 10 lines of soure code.

Thanks for having a look, I will send out a V2 that removes
ISOLATE_UNEVICTABLE and the check in __isolate_lru_page().

Eric

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU/dLBAAoJELbVsDOpoOa9xfIP/R4oju4qqvlAS4eczr2ajl0Y
ufjDDgBxT/NuKufYKtmMztrSHOItFhIHYnx9zjavYq0C/FL1ajoR9DvjghA/Im78
pNEL8tk5OzdkPB75bOvNjmTNuNCGZOElGLy50wqBDhO+EHELX3ZycEuuTs8q9kfl
QmGYxKPEj1X4P1THG4m/823CelitvYgTbyOWr5Jk5qsuAz5K3d1sVFR1nFUyhtGJ
XirKnwplBMyAEi+FnffWUmmm3qEB/tHOf1dtyzQf5q0pB2luoz72m+Jv/PdgDDmH
3sFISFUQjjrvPqDC5RGL7GAFpzkj+d2ZGLGUP9i2HhBlU7imPuaEJx6V3N9y545I
FK+Kao71L3wWEygcE/C5Ldu62lV+RJTAxxkqXY0veel/KmmxfH4ggLPDZq+B4Oym
g+HahZWMB4+qZDrwXoe9t4zytCZ8u59wKgedtBDBhJq2iZ8dB0M/SVzMaIlZ6d+5
1qTZU/LGqLX8q63awQ6yGQIkKP9XoOBmJGzuTFDWvGjH6k6xAL5zblbpyNwODoNq
ZqPv0WZY09zSCaAasncbB/5DrFqPaJlSw75jObdkIJMQ7RY+yhkgnH7aPnPSseYp
s7+esvkC4wbHOOtA7ayDJGxBLd6sFeaIX4mpFJAlAbJ4NmSp6mowtDNspaataX5e
HlqGCxo8cAGonbXEFJ4a
=5YZm
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

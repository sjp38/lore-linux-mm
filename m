Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i4CGU00m024386
	for <linux-mm@kvack.org>; Wed, 12 May 2004 12:30:00 -0400
Received: from [172.31.3.35] (arjanv.cipe.redhat.com [10.0.2.48])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4CGTx332714
	for <linux-mm@kvack.org>; Wed, 12 May 2004 12:29:59 -0400
Subject: Re: The long, long life of an inactive_dirty page
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <200405121528.i4CFSfOn057287@newsguy.com>
References: <200405121528.i4CFSfOn057287@newsguy.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-lAXNSpq5bV5S3JeaDslY"
Message-Id: <1084379397.10949.4.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Wed, 12 May 2004 18:29:57 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-lAXNSpq5bV5S3JeaDslY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2004-05-12 at 17:28, Andrew Crawford wrote:
> Arjan van de Ven wrote:
>=20
> >bdflush and co WILL commit the data to disk after like 30 seconds.
> >They will not move it to inactive_clean; that will happen at the first
> >sight of memory pressure. The code that does that notices that the data
> >isn't dirty and won't do a write-out just a move.
>=20
> Thanks for that. I have a couple of follow-up questions if I may be so bo=
ld:

well you may IF you fix  your mail setup to not send me evil mails about
having to confirm something.

>=20
> 1. Is there any way, from user space, to distinguish inactive_dirty pages
> which have actually been written from those which haven't?

no, in fact the kernel doesn't know until it looks at the pages (which
it only does on demand). One thing to realize is that after bdflush has
written the pages out, they can become dirty AGAIN for a variety of
reasons, and as such the accounting is not quite straightforward.


> 2. Is there any reason, conceptually, that bdflush shouldn't move the pag=
es to
> the inactive_clean list as page_launder does? After all, they become "kno=
wn
> clean" at that point, not X hours later when there is a memory shortfall.

the problem is that the "becoming clean" is basically asynchronous,
which would mean the LRU order (FIFO basically) would be destroyed.
(there's implementation issues as well wrt lock ranking etc etc but
that's details)

--=-lAXNSpq5bV5S3JeaDslY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAolEFxULwo51rQBIRAscTAJ4sqd/27reX7cYitBbkUrluVEjMkACgpsH0
eS7c/pb55xn5oPqur/KKwU8=
=XnPV
-----END PGP SIGNATURE-----

--=-lAXNSpq5bV5S3JeaDslY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

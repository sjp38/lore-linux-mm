Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDD5028026B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 21:01:42 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 188so3524051iti.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:01:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u126si250472iod.223.2016.09.26.18.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 18:01:42 -0700 (PDT)
Message-ID: <1474938096.17726.62.camel@redhat.com>
Subject: Re: page_waitqueue() considered harmful
From: Rik van Riel <riel@redhat.com>
Date: Mon, 26 Sep 2016 21:01:36 -0400
In-Reply-To: <20160926231132.GA17069@node.shutemov.name>
References: 
	<CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	 <1474925009.17726.61.camel@redhat.com>
	 <20160926231132.GA17069@node.shutemov.name>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ujyPCaCXpD6Dcfd1Z7Wg"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>


--=-ujyPCaCXpD6Dcfd1Z7Wg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-09-27 at 02:11 +0300, Kirill A. Shutemov wrote:
> On Mon, Sep 26, 2016 at 05:23:29PM -0400, Rik van Riel wrote:
> >=20
> > On Mon, 2016-09-26 at 13:58 -0700, Linus Torvalds wrote:
> >=20
> > >=20
> > > Is there really any reason for that incredible indirection? Do we
> > > really want to make the page_waitqueue() be a per-zone thing at
> > > all?
> > > Especially since all those wait-queues won't even be *used*
> > > unless
> > > there is actual IO going on and people are really getting into
> > > contention on the page lock.. Why isn't the page_waitqueue() just
> > > one
> > > statically sized array?
> >=20
> > Why are we touching file pages at all during fork()?
>=20
> We are not.
> Unless the vma has private pages (vma->anon_vma is not NULL).
>=20
> See first lines for copy_page_range().

Ahhh, indeed. I thought I remembered an optimization like
that.

--=20
All Rights Reversed.
--=-ujyPCaCXpD6Dcfd1Z7Wg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX6cTxAAoJEM553pKExN6D2WcH/jt6JL9rw3xMuFsO9pfsBSIo
ZRXxXsE3bo0oHSEmGJxN20SzFcpdrHKe6uFOQ3spFV+iIX1bWh7th4PZopNyn/uf
rj7Zx+rAl1syFodV/rhFTPpxikIFL5V/TZ6lr7cJ12LhH5MGYk/Pz0A6zBAO/629
BtoamnGFhH9Udk4je/78XxB8w3LBLfCNiarPokIotgAWvlEqQTu1UTeJ756A3VZC
gbDARHFaF8KKYLX0zz9au4GuGUt003585yW76rE7FLmpvc3Q6k9+RhcdyaJUDRNL
qiRmpzJsxKBP6qaTKhJbE1M97wqlopY0pOcjv9llzOl8DP0KIV74BosssUv0/O0=
=e4dC
-----END PGP SIGNATURE-----

--=-ujyPCaCXpD6Dcfd1Z7Wg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

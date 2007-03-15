Message-Id: <200703151737.l2FHb81d001600@turing-police.cc.vt.edu>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
In-Reply-To: Your message of "Wed, 14 Mar 2007 22:33:17 BST."
             <20070314213317.GA22234@rhlx01.hs-esslingen.de>
From: Valdis.Kletnieks@vt.edu
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <1173905741.8763.36.camel@kleikamp.austin.ibm.com>
            <20070314213317.GA22234@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1173980228_1561P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Mar 2007 13:37:08 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1173980228_1561P
Content-Type: text/plain; charset=us-ascii

On Wed, 14 Mar 2007 22:33:17 BST, Andreas Mohr said:

> it'd seem we need some kind of state management here to figure out good
> intervals of when to call mark_page_accessed() *again* for this page. E.g.
> despite non-changing access patterns you could still call mark_page_accessed(
)
> every 32 calls or so to avoid expiry, but this would need extra helper
> variables.

What if you did something like

	if (jiffies%32) {...

(Possibly scaling it so the low-order bits change).  No need to lock it, as
"right most of the time" is close enough.


--==_Exmh_1173980228_1561P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFF+YREcC3lWbTT17ARAhW1AKCuB8pEi0Xy+IlCzPJu/Zdq7zvedQCghfET
sfCGp4YNiB2ouYFsn+utLpY=
=3nRc
-----END PGP SIGNATURE-----

--==_Exmh_1173980228_1561P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

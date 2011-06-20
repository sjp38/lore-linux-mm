Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 597D86B0012
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 02:06:34 -0400 (EDT)
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [PATCH] fix cleancache config
Date: Mon, 20 Jun 2011 08:06:26 +0200
Message-ID: <4186233.iG38M59heg@donald.sf-tec.de>
In-Reply-To: <20110619215026.GA17202@infradead.org>
References: <7182365.DrQ0shW2IG@donald.sf-tec.de> <20110619215026.GA17202@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3973522.GRxUXsnehz"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org


--nextPart3973522.GRxUXsnehz
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Christoph Hellwig wrote:
> On Sun, Jun 19, 2011 at 05:29:55PM +0200, Rolf Eike Beer wrote:
> > >From 2b3ebe8ffd22793dc53f4b7301048d60e8db017e Mon Sep 17 00:00:00 2001
> > 
> > From: Rolf Eike Beer <eike-kernel@sf-tec.de>
> > Date: Thu, 9 Jun 2011 14:13:58 +0200
> > Subject: [PATCH] fix cleancache config
> > 
> > It doesn't make sense to have a default setting different to that what
> > we
> > suggest the user to select. Also fixes a typo.
> 
> NAK
> 
> default y is not for random crap, but for essential bits that should
> only be explicitly disabled if you really know what you do.

So you want the user to enable this if he reads the help text but not to 
enable this when he does not? This is totally senseless.

Eike
--nextPart3973522.GRxUXsnehz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk3+42gACgkQXKSJPmm5/E5wCQCdF3JbU8pdsSTTbQPSLf9ztNHN
q1cAniQrFBXE3YB1uGG40f+3753ZdJM8
=6tLt
-----END PGP SIGNATURE-----

--nextPart3973522.GRxUXsnehz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

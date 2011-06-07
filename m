Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 676256B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 14:05:48 -0400 (EDT)
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in dmam_pool_destroy()
Date: Tue, 07 Jun 2011 20:05:33 +0200
Message-ID: <3838457.LEWxWdrTRM@donald.sf-tec.de>
In-Reply-To: <BANLkTimYw-WAK3Hd21XQWrjBn_1+wRMzUQ@mail.gmail.com>
References: <20110602142242.GA4115@maxin> <BANLkTimYw-WAK3Hd21XQWrjBn_1+wRMzUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1413092.VXQfqmDd7c"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin B John <maxin.john@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, tj@kernel.org, jkosina@suse.cz, tglx@linutronix.de


--nextPart1413092.VXQfqmDd7c
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

Maxin B John wrote:

> Could you please let me know your thoughts on this patch ?

Makes absolute sense to me.

Reviewed-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
--nextPart1413092.VXQfqmDd7c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk3uaHUACgkQXKSJPmm5/E6dUACgoXEdYs0c2uDWctkpQRSm5IVR
OeoAoJEQ9gJhrNKozle8sQMgKuM3qZUC
=e+0O
-----END PGP SIGNATURE-----

--nextPart1413092.VXQfqmDd7c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

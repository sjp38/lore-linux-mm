Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4A36B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 11:06:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 124so66207012itl.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:06:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v124si26623609itc.68.2016.09.29.08.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 08:05:47 -0700 (PDT)
Message-ID: <1475161541.10218.117.camel@redhat.com>
Subject: Re: page_waitqueue() considered harmful
From: Rik van Riel <riel@redhat.com>
Date: Thu, 29 Sep 2016 11:05:41 -0400
In-Reply-To: <20160929225544.70a23dac@roar.ozlabs.ibm.com>
References: 
	<CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	 <20160927073055.GM2794@worktop> <20160927085412.GD2838@techsingularity.net>
	 <20160929080130.GJ3318@worktop.controleur.wifipass.org>
	 <20160929225544.70a23dac@roar.ozlabs.ibm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-205UbcDYhsUtsMFgFzSW"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>


--=-205UbcDYhsUtsMFgFzSW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-09-29 at 22:55 +1000, Nicholas Piggin wrote:

> PG_swapcache - can this be replaced with ane of the private bits, I
> wonder?

Perhaps. page->mapping needs to be free to point
at the anon_vma, but from the mapping pointer we
can see that the page is swap backed.

Is there any use for page->private for swap
backed pages that is not the page cache index?

If so, (PageAnon(page) && page->private)
might work as a replacement for PG_swapcache.

That might catch some false positives with
the special swap types used for migration, but
maybe we do not need to care about those (much),
or we can filter them out with a more in-depth
check?

--=20
All rights reversed

--=-205UbcDYhsUtsMFgFzSW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX7S3GAAoJEM553pKExN6DTbEH/2hYVFxrgxo6nHkEsvXZzIP5
yTagwEYMiLadpQSwDBxfI/iWvQvlQy6e9innRPnINYa4KcAbqdB7dnKpzT0FM8WP
xPWEU8Vz9GKgobHs9pkGNBWI/1c7TLtU4bNCRoUhvYS9ElSxc25F5BorF1pMMpOV
1qZIIgfPr9bx6SNR32QnG3C4YxuRCHrI5kUCZpzV0JH7buAyGXGhWd9E/b56Pkio
rDTruDnjpt1AfvdCWCTXullltRDjo/BzH1+PlNYiaeHZnVRpb54bh7qtWEzKxDKy
TgjIH6+yOAy+g6Z2IuhlzSS4RvhUm5QcspIQVCLt1yfoJuCYdvLGvXipYKgpGZg=
=qv6d
-----END PGP SIGNATURE-----

--=-205UbcDYhsUtsMFgFzSW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

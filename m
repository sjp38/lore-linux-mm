Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
In-Reply-To: Your message of "Tue, 11 Nov 2008 15:03:45 MST."
             <20081111150345.7fff8ff2@bike.lwn.net>
From: Valdis.Kletnieks@vt.edu
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <1226409701-14831-4-git-send-email-ieidus@redhat.com>
            <20081111150345.7fff8ff2@bike.lwn.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1226443216_3887P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 11 Nov 2008 17:40:16 -0500
Message-ID: <23027.1226443216@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

--==_Exmh_1226443216_3887P
Content-Type: text/plain; charset=us-ascii

On Tue, 11 Nov 2008 15:03:45 MST, Jonathan Corbet said:

> > +#define PAGECMP_OFFSET 128
> > +#define PAGEHASH_SIZE (PAGECMP_OFFSET ? PAGECMP_OFFSET : PAGE_SIZE)
> > +/* hash the page */
> > +static void page_hash(struct page *page, unsigned char *digest)
> 
> So is this really saying that you only hash the first 128 bytes, relying on
> full compares for the rest?  I assume there's a perfectly good reason for
> doing it that way, but it's not clear to me from reading the code.  Do you
> gain performance which is not subsequently lost in the (presumably) higher
> number of hash collisions?

Seems reasonably sane to me - only doing the first 128 bytes rather than
a full 4K page is some 32 times faster.  Yes, you'll have the *occasional*
case where two pages were identical for 128 bytes but then differed, which is
why there's buckets.  But the vast majority of the time, at least one bit
will be different in the first part.

In fact, I'd not be surprised if only going for 64 bytes works well...

--==_Exmh_1226443216_3887P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJGgnQcC3lWbTT17ARAlPaAKCJ13v2zxBAEeCBOwc54FDvcFVHAQCfXw1N
mk26Q65TvGS4aSjLOuWvCfU=
=Vsok
-----END PGP SIGNATURE-----

--==_Exmh_1226443216_3887P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 716A96B02AF
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:19:10 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o14so10368598wrf.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:19:10 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id n194si3688673wmg.259.2017.11.22.08.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 08:19:09 -0800 (PST)
Date: Wed, 22 Nov 2017 17:19:07 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171122161907.GA12684@amd>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> KAISER makes it harder to defeat KASLR, but makes syscalls and
> interrupts slower.  These patches are based on work from a team at
> Graz University of Technology posted here[1].  The major addition is
> support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
> work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
> for a wide variety of use cases.

Is it useful?

> Full Description:
>=20
> KAISER is a countermeasure against attacks on kernel address
> information.  There are at least three existing, published,
> approaches using the shared user/kernel mapping and hardware features
> to defeat KASLR.  One approach referenced in the paper locates the
> kernel by observing differences in page fault timing between
> present-but-inaccessable kernel pages and non-present pages.

I mean... evil userspace will still be able to determine kernel's
location using cache aliasing effects, right?
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAloVo3sACgkQMOfwapXb+vIG4ACeOWzVb819E5m4e8mS0CQU2u35
xeQAn1Nj43UAPZWfdEGY4tlyVYRxIUr4
=dxs0
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

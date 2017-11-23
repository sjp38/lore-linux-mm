Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3473B6B0271
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:47:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v8so11742153wrd.21
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:47:55 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id a15si4808530wmg.202.2017.11.23.02.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 02:47:54 -0800 (PST)
Date: Thu, 23 Nov 2017 11:47:52 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171123104752.GB17990@amd>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171122161907.GA12684@amd>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9zSXsLTf0vkW971A"
Content-Disposition: inline
In-Reply-To: <20171122161907.GA12684@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--9zSXsLTf0vkW971A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2017-11-22 17:19:07, Pavel Machek wrote:
> Hi!
>=20
> > KAISER makes it harder to defeat KASLR, but makes syscalls and
> > interrupts slower.  These patches are based on work from a team at
> > Graz University of Technology posted here[1].  The major addition is
> > support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
> > work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
> > for a wide variety of use cases.
>=20
> Is it useful?
>=20
> > Full Description:
> >=20
> > KAISER is a countermeasure against attacks on kernel address
> > information.  There are at least three existing, published,
> > approaches using the shared user/kernel mapping and hardware features
> > to defeat KASLR.  One approach referenced in the paper locates the
> > kernel by observing differences in page fault timing between
> > present-but-inaccessable kernel pages and non-present pages.
>=20
> I mean... evil userspace will still be able to determine kernel's
> location using cache aliasing effects, right?

Issues with AnC attacks are tracked via several CVE identifiers.

CVE-2017-5925 is assigned to track the developments for Intel processors
CVE-2017-5926 is assigned to track the developments for AMD processors

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--9zSXsLTf0vkW971A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAloWp1gACgkQMOfwapXb+vJ/EwCdE+s8rl/8J9z8zG5LklwlSeNT
E5UAoJlIldkJu8PK08DYWCYOi6BvpMG7
=Us5Y
-----END PGP SIGNATURE-----

--9zSXsLTf0vkW971A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

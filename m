Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D93F6B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:52:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u1-v6so468589wrs.18
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 11:52:54 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id l132-v6si2610085wmb.65.2018.06.28.11.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 11:52:52 -0700 (PDT)
Date: Thu, 28 Jun 2018 20:52:51 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv3 00/17] MKTME enabling
Message-ID: <20180628185251.GB5316@amd>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PmA2V3Z32TCmWXqI"
Content-Disposition: inline
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--PmA2V3Z32TCmWXqI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> MKTME is built on top of TME. TME allows encryption of the entirety of
> system memory using a single key. MKTME allows to have multiple encryption
> domains, each having own key -- different memory pages can be encrypted
> with different keys.
>=20
> Key design points of Intel MKTME:
>=20
>  - Initial HW implementation would support upto 63 keys (plus one
> default

"up to"

>    TME key). But the number of keys may be as low as 3, depending to SKU
>    and BIOS settings
>=20
>  - To access encrypted memory you need to use mapping with proper KeyID
>    int the page table entry. KeyID is encoded in upper bits of PFN in page

"in the"

>    table entry.
>=20
>  - CPU does not enforce coherency between mappings of the same physical
>    page with different KeyIDs or encryption keys. We wound need to take

"would need"

>    care about flushing cache on allocation of encrypted page and on
>    returning it back to free pool.
>=20
>  - For managing keys, there's MKTME_KEY_PROGRAM leaf of the new PCONFIG
>    (platform configuration) instruction. It allows load and clear keys
>    associated with a KeyID. You can also ask CPU to generate a key for
>    you or disable memory encryption when a KeyID is used.

Should this go to Documentation somewhere?

And next question is -- what is it good for? Prevents attack where
DRAM is frozen by liquid nitrogen and moved to another system to
extract encryption keys? Does it prevent any attacks that don't
involve manipulating hardware?

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PmA2V3Z32TCmWXqI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAls1LoMACgkQMOfwapXb+vJ5mACglt4/cRyb/gt/KHOTiwID1t8V
NhoAoKR8mceQbY+kMGFkXIOM0SabWH1J
=JaRN
-----END PGP SIGNATURE-----

--PmA2V3Z32TCmWXqI--

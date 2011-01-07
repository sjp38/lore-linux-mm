Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F26B26B00D1
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 18:42:20 -0500 (EST)
Date: Sat, 8 Jan 2011 10:42:08 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2011-01-06-15-41 uploaded
Message-Id: <20110108104208.ca085298.sfr@canb.auug.org.au>
In-Reply-To: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
References: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__8_Jan_2011_10_42_08_+1100_eRk2QF3kFcTaDAx="
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

--Signature=_Sat__8_Jan_2011_10_42_08_+1100_eRk2QF3kFcTaDAx=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 06 Jan 2011 15:41:14 -0800 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2011-01-06-15-41 has been uploaded to
>=20
>    http://userweb.kernel.org/~akpm/mmotm/

Build results here: http://kisskb.ellerman.id.au/kisskb/head/3605/

Notably:

powerpc pmac32_defconfig:

In file included from arch/powerpc/include/asm/pgtable.h:200,
                 from include/linux/mm.h:41,
                 from include/linux/mman.h:14,
                 from arch/powerpc/kernel/asm-offsets.c:22:
include/asm-generic/pgtable.h: In function 'pmdp_get_and_clear':
include/asm-generic/pgtable.h:96: warning: missing braces around initializer
include/asm-generic/pgtable.h:96: warning: (near initialization for '(anony=
mous).pud')

sparc defconfig:

In file included from arch/sparc/include/asm/pgtable_32.h:456,
                 from arch/sparc/include/asm/pgtable.h:7,
                 from include/linux/mm.h:42,
                 from arch/sparc/kernel/sys_sparc_32.c:12:
include/asm-generic/pgtable.h: In function 'pmdp_get_and_clear':
include/asm-generic/pgtable.h:96: error: missing braces around initializer
include/asm-generic/pgtable.h:96: error: (near initialization for '(anonymo=
us).pmdv')

Probably a side effect of
thp-add-pmd-mangling-generic-functions-fix-pgtableh-build-for-um.patch.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__8_Jan_2011_10_42_08_+1100_eRk2QF3kFcTaDAx=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNJ6TQAAoJEDMEi1NhKgbs45UH/0hT/IP5It4HDHPot2apZczn
gVdG13HzudAts6bATYv5xG5afFFomUXqaaaId+xBUHdxdyEv8lNqBuTFQppyqzbf
dsW2JjQT1sB6Spm4k0wn0sLWSu6pyVRP0AaC0X6UreFEulkhcCMLAzYq4cFEhaOj
N9Ho2w+8X9Gp0BEZ9OtJpRzSEOBEOCHRaDQ4pDLHP1FQmzQHxWSf1V4mXfi+I8Is
PDFFkQFuNT2jEJZ8aJJiZx/bUilos8KhPIqt5sKYdi9E6QGH2f/qsouz6vF9U4Rx
kabXk0c0f7Y0znUsp+e8mxBGAyoK3pUeDNxeNNGmAZrAd7tdzHQN735dJpz9wNE=
=ZsXa
-----END PGP SIGNATURE-----

--Signature=_Sat__8_Jan_2011_10_42_08_+1100_eRk2QF3kFcTaDAx=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

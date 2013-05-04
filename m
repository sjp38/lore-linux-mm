Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D0F276B0309
	for <linux-mm@kvack.org>; Sat,  4 May 2013 02:33:15 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Sat, 4 May 2013 16:25:00 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A15072CE804A
	for <linux-mm@kvack.org>; Sat,  4 May 2013 16:33:06 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r446Ww9521168242
	for <linux-mm@kvack.org>; Sat, 4 May 2013 16:32:59 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r446X4sE006348
	for <linux-mm@kvack.org>; Sat, 4 May 2013 16:33:05 +1000
Date: Sat, 4 May 2013 16:28:25 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 04/10] powerpc: Update find_linux_pte_or_hugepte to
 handle transparent hugepages
Message-ID: <20130504062825.GY13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130503045323.GP13041@truffula.fritz.box>
 <87ip2z51rn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5OPIRG5sBUHnKBkK"
Content-Disposition: inline
In-Reply-To: <87ip2z51rn.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--5OPIRG5sBUHnKBkK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 04, 2013 at 12:28:20AM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Mon, Apr 29, 2013 at 01:21:45AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >
> > What's the difference in meaning between pmd_huge() and pmd_large()?
> >
>=20
> #ifndef CONFIG_HUGETLB_PAGE
> #define pmd_huge(x)	0
> #endif
>=20
> Also pmd_large do check for THP PTE flag, and _PAGE_PRESENT.

I don't mean what's the code difference.  I mean what is the semantic
difference between pmd_huge() and pmd_large() supposed to be - in
words.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--5OPIRG5sBUHnKBkK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGEqokACgkQaILKxv3ab8YR7ACeIEQXWQ200IRwwwUy4XG/QqnR
VjkAn0XwLDa00t5eDnow51Yfq1F6Rc0V
=R2xM
-----END PGP SIGNATURE-----

--5OPIRG5sBUHnKBkK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

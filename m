Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A35116B02D5
	for <linux-mm@kvack.org>; Fri,  3 May 2013 08:02:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 21:50:06 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 940F5357804E
	for <linux-mm@kvack.org>; Fri,  3 May 2013 22:02:18 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43BmN9G23789678
	for <linux-mm@kvack.org>; Fri, 3 May 2013 21:48:24 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43C2HTe028762
	for <linux-mm@kvack.org>; Fri, 3 May 2013 22:02:17 +1000
Date: Fri, 3 May 2013 21:54:28 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
Message-ID: <20130503115428.GW13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130503045201.GO13041@truffula.fritz.box>
 <1367569143.4389.56.camel@pasglop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LvnU4bbuCGLV8PtK"
Content-Disposition: inline
In-Reply-To: <1367569143.4389.56.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, paulus@samba.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

--LvnU4bbuCGLV8PtK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 03, 2013 at 06:19:03PM +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2013-05-03 at 14:52 +1000, David Gibson wrote:
> > Here, specifically, the fact that PAGE_BUSY is in PAGE_THP_HPTEFLAGS
> > is likely to be bad.  If the page is busy, it's in the middle of
> > update so can't stably be considered the same as anything.
>=20
> _PAGE_BUSY is more like a read lock. It means it's being hashed, so what
> is not stable is _PAGE_HASHPTE, slot index, _ACCESSED and _DIRTY. The
> rest is stable and usually is what pmd_same looks at (though I have a
> small doubt vs. _ACCESSED and _DIRTY but at least x86 doesn't care since
> they are updated by HW).

Ok.  It still seems very odd to me that _PAGE_BUSY would be in the THP
version of _PAGE_HASHPTE, but not the normal one.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--LvnU4bbuCGLV8PtK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDpXQACgkQaILKxv3ab8a7/gCdHO5XO3PKrvuxj1xHqileGtEd
nzQAmwSHLCB4TPuaZf2HAq7JjiFYwtvX
=NaVi
-----END PGP SIGNATURE-----

--LvnU4bbuCGLV8PtK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

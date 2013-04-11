Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 759626B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 02:19:19 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 16:07:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6D4A43578050
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:19:13 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B65Op155640152
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:05:24 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B6IgKc006574
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:18:43 +1000
Date: Thu, 11 Apr 2013 16:18:35 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 18/25] powerpc/THP: Double the PMD table size for THP
Message-ID: <20130411061835.GH8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kUr9BK2/TCCh1PYv"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--kUr9BK2/TCCh1PYv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:56AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> THP code does PTE page allocation along with large page request and depos=
it them
> for later use. This is to ensure that we won't have any failures when we =
split
> hugepages to regular pages.
>=20
> On powerpc we want to use the deposited PTE page for storing hash pte slo=
t and
> secondary bit information for the HPTEs. We use the second half
> of the pmd table to save the deposted PTE page.

The previous patch accesses data in that second half of the PMD table,
so this patch should go before it.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--kUr9BK2/TCCh1PYv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmVbsACgkQaILKxv3ab8Z7igCfQFP08UqGTcSoCvL7Uoh0gh2a
hC0AnjGnaz4B06XmMwdlMbPxCxqJdSkB
=iQxQ
-----END PGP SIGNATURE-----

--kUr9BK2/TCCh1PYv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

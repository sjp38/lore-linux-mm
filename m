Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0D1126B0036
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:42:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 13:35:03 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0FEC32CE8059
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:57 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B3SQZ4852242
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:28:28 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B3frCO030866
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:54 +1000
Date: Thu, 11 Apr 2013 13:36:30 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 14/25] mm/THP: HPAGE_SHIFT is not a #define on some
 arch
Message-ID: <20130411033630.GW8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1RhGCd1AsoFHGRHc"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--1RhGCd1AsoFHGRHc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:52AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> On archs like powerpc that support different hugepage sizes, HPAGE_SHIFT
> and other derived values like HPAGE_PMD_ORDER are not constants. So move
> that to hugepage_init
>=20
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Looks ok to me.

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--1RhGCd1AsoFHGRHc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmL74ACgkQaILKxv3ab8YcUwCeMKdk6ikoFsSr6xcqWGiLnZZU
n64AnibCF60GD5PwxFf5QiQcXnKwhCns
=jkNj
-----END PGP SIGNATURE-----

--1RhGCd1AsoFHGRHc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E166A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:42:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 13:35:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 89B1F2BB0055
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:55 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B3fn9p53084298
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:50 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B3fsaW032051
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:54 +1000
Date: Thu, 11 Apr 2013 13:24:47 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 12/25] powerpc: Return all the valid pte ecndoing in
 KVM_PPC_GET_SMMU_INFO ioctl
Message-ID: <20130411032447.GU8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qa1NXTiqN6KSzHv0"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--qa1NXTiqN6KSzHv0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:50AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Surely this can't be correct until the KVM H_ENTER implementation is
updated to cope with the MPSS page sizes.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--qa1NXTiqN6KSzHv0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEUEARECAAYFAlFmLP8ACgkQaILKxv3ab8YlVwCWIhJXZSJXrFW7757E9EqrYOcP
9QCghxCXvtNQPjEjS5gNVm5QvXmIIcA=
=6LtF
-----END PGP SIGNATURE-----

--qa1NXTiqN6KSzHv0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

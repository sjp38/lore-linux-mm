Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 135CE6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 20:22:41 -0500 (EST)
Date: Fri, 22 Feb 2013 11:32:35 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [RFC PATCH -V2 05/21] powerpc: Reduce PTE table memory wastage
Message-ID: <20130222003235.GJ21011@truffula.fritz.box>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361465248-10867-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jIYo0VRlfdMI9fLa"
Content-Disposition: inline
In-Reply-To: <1361465248-10867-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org


--jIYo0VRlfdMI9fLa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 21, 2013 at 10:17:12PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We now have PTE page consuming only 2K of the 64K page.This is in order to
> facilitate transparent huge page support, which works much better if our =
PMDs
> cover 16MB instead of 256MB.
>=20
> Inorder to reduce the wastage, we now have multiple PTE page fragment
> from the same PTE page.

This needs a much better description of what you're doing here to
manage the allocations.  It's certainly not easy to figure out from
the code.


[snip]
> +#ifdef CONFIG_PPC_64K_PAGES
> +typedef pte_t *pgtable_t;
> +#else
>  typedef struct page *pgtable_t;
> +#endif

This looks really bogus.  A pgtable_t is a pointer to PTEs on 64K, but
a pointer to a struct page on 4k.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--jIYo0VRlfdMI9fLa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlEmvKMACgkQaILKxv3ab8aRMQCeOlWmhsYrGIGG9+5J0ADAmUQL
LyoAoIZQNeQEdS8G2DD4s+Ch/Z2rkEVv
=dYoL
-----END PGP SIGNATURE-----

--jIYo0VRlfdMI9fLa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

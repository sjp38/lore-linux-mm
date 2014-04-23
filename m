Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 21DA26B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:10:32 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1221883pbc.15
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:10:31 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id bi5si1395758pbb.62.2014.04.23.15.10.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 15:10:30 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:10:19 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
Message-Id: <20140424081019.596b5d23c624f5721ba0480a@canb.auug.org.au>
In-Reply-To: <20140423112442.5a5c8f23d580a65575e0c5fc@linux-foundation.org>
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
	<5357F405.20205@infradead.org>
	<20140423134131.778f0d0a@redhat.com>
	<5357FCEB.2060507@infradead.org>
	<20140423141600.4a303d95@redhat.com>
	<20140423112442.5a5c8f23d580a65575e0c5fc@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Apr_2014_08_10_19_+1000_C5fgHkTa+5.T.lB_"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com, Richard Weinberger <richard@nod.at>

--Signature=_Thu__24_Apr_2014_08_10_19_+1000_C5fgHkTa+5.T.lB_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 23 Apr 2014 11:24:42 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> I'll try moving hugepages_supported() into the #ifdef
> CONFIG_HUGETLB_PAGE section.
>=20
> --- a/include/linux/hugetlb.h~hugetlb-ensure-hugepage-access-is-denied-if=
-hugepages-are-not-supported-fix-fix
> +++ a/include/linux/hugetlb.h
> @@ -412,6 +412,16 @@ static inline spinlock_t *huge_pte_lockp
>  	return &mm->page_table_lock;
>  }
> =20
> +static inline bool hugepages_supported(void)
> +{
> +	/*
> +	 * Some platform decide whether they support huge pages at boot
> +	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> +	 * there is no such support
> +	 */
> +	return HPAGE_SHIFT !=3D 0;
> +}
> +
>  #else	/* CONFIG_HUGETLB_PAGE */
>  struct hstate {};
>  #define alloc_huge_page_node(h, nid) NULL
> @@ -460,14 +470,4 @@ static inline spinlock_t *huge_pte_lock(
>  	return ptl;
>  }
> =20
> -static inline bool hugepages_supported(void)
> -{
> -	/*
> -	 * Some platform decide whether they support huge pages at boot
> -	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> -	 * there is no such support
> -	 */
> -	return HPAGE_SHIFT !=3D 0;
> -}
> -
>  #endif /* _LINUX_HUGETLB_H */

Clearly, noone reads my emails :-(

This is exactly what I reported and the fix I applied to yesterday's
linux-next ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__24_Apr_2014_08_10_19_+1000_C5fgHkTa+5.T.lB_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWDpRAAoJEMDTa8Ir7ZwVKVAP/AkvWVgtYaFlN2HpaXXZ2b86
6149Yd/RBCxH3exY5J0hBrSYtc2nvsA60p/d6TfWll0EBA9cVPv5AyNhWqmEtjlS
QMfCnlgaK4MMR2R+E2xL764sQsGQZRilgdDShe0ukgyfT6+CcPRrWCN3WaoCQTl4
SEF8gFmdPeZ0I242CXJnBvge6/gRlssSyXhExP+63aqPi9mJiM1/Aj396el413hx
o1uBRcN8ur3d9x2iyrOsMTwdVdd40Q1f1b+4rHpsiHkLgrbpK6Rx6LZy7KPdCsHI
Pykpd2ccXvIHCo7tfF7CURRlu/iIyJFSFnHy1JErVcJC5tyx3AMiQDbKb/vYQdeN
YVIYVybX0TX20cVLz2cua5sW3o/gPmtIaibELGmz05LGP0aHd+sQ/82DBrTHrW9T
0limrH7vIk3WkO8T1fRzPxg3Dq4VsD/suWD6SllsZlYEMJpdQH9Y+oDiPlF5uisL
2uGG5J3qvkmu1DR3MGT449zebYjF8NtvYeBLxM+oN/Nbw4+tQiG10yMoL5LasaRQ
f1D8EPcTSxU618j0/22VJC1fIpkNrV0rmqnAT6+MO+gYxbylpZFjVp61X3y5JwOT
y9dkPW9sU4SdG1Q3MDOaZx9SuNDfsM1F8W1NyLEUEwSUi6pdPIPd3kRUISCmpQp7
7EiBVPN49Ol6GFGbKdyV
=Z0Qm
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Apr_2014_08_10_19_+1000_C5fgHkTa+5.T.lB_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

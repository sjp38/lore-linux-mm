Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 182F683207
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:57:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l64so14296777pfb.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:57:22 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id h67si208223pgc.393.2017.05.09.19.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 19:57:21 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id w69so2148350pfk.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:57:21 -0700 (PDT)
Date: Wed, 10 May 2017 10:57:21 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH -mm] mm, swap: Remove unused function prototype
Message-ID: <20170510025721.GC8480@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170405071017.23677-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="UFHRwCdBEJvubb2X"
Content-Disposition: inline
In-Reply-To: <20170405071017.23677-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>


--UFHRwCdBEJvubb2X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 05, 2017 at 03:10:17PM +0800, Huang, Ying wrote:
>From: Huang Ying <ying.huang@intel.com>
>
>This is a code cleanup patch, no functionality changes.  There are 2
>unused function prototype in swap.h, they are removed.
>
>Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>Cc: Tim Chen <tim.c.chen@linux.intel.com>
>---
> include/linux/swap.h | 3 ---
> 1 file changed, 3 deletions(-)
>
>diff --git a/include/linux/swap.h b/include/linux/swap.h
>index 486494e6b2fc..ba5882419a7d 100644
>--- a/include/linux/swap.h
>+++ b/include/linux/swap.h
>@@ -411,9 +411,6 @@ struct backing_dev_info;
> extern int init_swap_address_space(unsigned int type, unsigned long nr_pa=
ges);
> extern void exit_swap_address_space(unsigned int type);
>=20
>-extern int get_swap_slots(int n, swp_entry_t *slots);
>-extern void swapcache_free_batch(swp_entry_t *entries, int n);
>-
> #else /* CONFIG_SWAP */
>=20
> #define swap_address_space(entry)		(NULL)
>--=20
>2.11.0

Reviewed-by: Wei Yang <richard.weiyang@gmail.com>

--=20
Wei Yang
Help you, Help me

--UFHRwCdBEJvubb2X
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZEoGRAAoJEKcLNpZP5cTd1osP/RZx40fMM10UAxyL4PvMCuAE
+gBeZ7y+eykytlE9jrF7eyVnJlYI1er1Qpd40Q8x0xr/Z+1p4xY8ReRIQNRZB9iW
7XaxfTwIvTncyyrBXhUibrAAhH4WQsPhnCikcnXB3fUVoyy9uI9boOMaTV+JT7eh
o4cymLzI/Aych2We3PzrAnJHqgE9XWeuGSQdCgJamHQyrI3SPIsW0fTMXjgZSdvt
pK1c+6obMfte+OgT6pu/11VPM+f8DHCVZonGJcCDEkTcCSDyVovt9rG7PT/6B5gu
hGvortGly0LluUQhaWeEWL0DK1xauv/Q+/Hh3wP0XzH8tj45mbqfhAkW26wSPJ/m
pNLQQI5LwrnJrC9MwCSdXOq5kiLcS3xONyJ72hsk73+bZVUNHWAL8CG2VHyrWxY5
+mCC4CL4KRPIhGLUwcHS9dkqwsUVpE1mjZE4OlZVNeNZjeQv475/oSW5CSVY0fSP
i0pAXj+nMcIzJsnPB7g63e2IzDFr8gt0tmI9jdVuF0hZYYCpxHwxkEMiwXPfMF7L
F/0qrbU0M80ySxun5Aa1N1BxvcyJVcKwQwJpFDrRh8/igbKlq/WMi3DtWbY5AzGG
J8jEvyvmZfFdQRHDkQFbgwTOK7TpvQ853vyXilwhuiNds7BHS57CmvPa0Iqum6p+
DrL+X5G47nx0aAIabUhS
=9y1G
-----END PGP SIGNATURE-----

--UFHRwCdBEJvubb2X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

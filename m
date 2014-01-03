Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1506B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 21:59:48 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so14869635pde.35
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 18:59:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ty3si44262174pbc.317.2014.01.02.18.59.46
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 18:59:47 -0800 (PST)
Date: Thu, 2 Jan 2014 21:40:38 -0500
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Re: [RFC PATCHv3 02/11] iommu/omap: Use get_vm_area directly
Message-ID: <20140103024038.GD1913@gchen.bj.intel.com>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
 <1388699609-18214-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Ycz6tD7Th1CMF4v7"
Content-Disposition: inline
In-Reply-To: <1388699609-18214-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org


--Ycz6tD7Th1CMF4v7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 02, 2014 at 01:53:20PM -0800, Laura Abbott wrote:
> diff --git a/drivers/iommu/omap-iovmm.c b/drivers/iommu/omap-iovmm.c
> index d147259..6280d50 100644
> --- a/drivers/iommu/omap-iovmm.c
> +++ b/drivers/iommu/omap-iovmm.c
> @@ -214,7 +214,7 @@ static void *vmap_sg(const struct sg_table *sgt)
>  	if (!total)
>  		return ERR_PTR(-EINVAL);
> =20
> -	new =3D __get_vm_area(total, VM_IOREMAP, VMALLOC_START, VMALLOC_END);
> +	new =3D get_vm_area(total, VM_IOREMAP);
This driver is a module but get_vm_area is not exported. You need to add
one extra EXPORT_SYMBOL_GPL(get_vm_area).


--Ycz6tD7Th1CMF4v7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSxiMmAAoJEI01n1+kOSLH9xgP/AhHieQaiUiJ0LAI2it3pQQx
dQiXOhvWANMFORGLj00UXRvQQlxs1jorUp4jxxUePWbqT+ZQvOVGIJZwmF3W0Vp3
bPLWbVCcYM1x0AtEqFTC0MRieBCdwK3MOhLN3eVvurWyXyPJD73wVmOGEqpXkLoG
cMMvfnf/w/V6fdTi3ryAwBn2E8aIrdLuU3FwooDSSl5PztLHXUSlkpqNrn5FnNBD
JNil5+clc619Nw1W3IYoCkOYrFQoxVjLgRlS9MfhyKMP+wt/iJmu+t6kI+OYJouV
OJRqjeu8syC8V+nZNkL/StzqthKTdCJbXJRy/GFFCePwzvacuEPmdAtQ3Dhyixvx
EAVzj4DbL2xEiz+v8iFisu6vz7i12VoKoTqSlb/Bz6VCKpQQ34lzU+axjsPOgZrU
4bDMlNdtGDPjASbjHxtSRfL+U6cJuDmH86zXenjzosBTD5MRnhOw80bagbejl30b
E65cHCCGstx2O9D691QHCnoVY6Xubqmq5HhWXS8Exl+72FiAUaN5pcTtTjsYcn1q
dyjPNfOTVhDMC/5mAMisiqxghMasXnMMUpDltc5s2mw5I5EnRQRSdfJzhJ75rxQW
y3R9ibRlO4DMnb+eeXknulaw1P3psQ1KW39CA9nh8rHHLdZ10OaAGs97VwlWkiQw
rUW2+MyROALPhKwm8NAy
=ud7f
-----END PGP SIGNATURE-----

--Ycz6tD7Th1CMF4v7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

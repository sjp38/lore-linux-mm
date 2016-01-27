Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA3606B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:06:54 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id 6so158133984qgy.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:06:54 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id k30si5378747qgk.52.2016.01.26.23.06.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 23:06:53 -0800 (PST)
Subject: Re: [PATCH] mm: fix pfn_t to page conversion in vm_insert_mixed
References: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Message-ID: <56A86C7D.6080708@ti.com>
Date: Wed, 27 Jan 2016 09:06:37 +0200
MIME-Version: 1.0
In-Reply-To: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="BiOdgKC1QB4OaMKo6JHuvhfGFbdlLLEjN"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, dri-devel@lists.freedesktop.org
Cc: Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, akpm@linux-foundation.org

--BiOdgKC1QB4OaMKo6JHuvhfGFbdlLLEjN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 26/01/16 20:37, Dan Williams wrote:
> pfn_t_to_page() honors the flags in the pfn_t value to determine if a
> pfn is backed by a page.  However, vm_insert_mixed() was originally
> written to use pfn_valid() to make this determination.  To restore the
> old/correct behavior, ignore the pfn_t flags in the !pfn_t_devmap() cas=
e
> and fallback to trusting pfn_valid().
>=20
> Fixes: 01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")

Thanks, this fixes the crash with omapdrm.

Tested-by: Tomi Valkeinen <tomi.valkeinen@ti.com>

 Tomi


--BiOdgKC1QB4OaMKo6JHuvhfGFbdlLLEjN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWqGx9AAoJEPo9qoy8lh71hkQP/jMqrvyEt5BTGxhouxeSpUE+
kIL+fJFVRpfeE+QO3bXRFyuXt6NoT9F+IGzPDBtEJHnc/7vdyDVpLoI+bP9PpqJM
R6faTLy2aE+7XG/2JrtUtk1XepsHyl4yOMEd3vpKh60PIAc+YhEC0PCDOgoyJnHW
XOlhNoloY/bIBP1NHwbK3ZgR70KIhCBQlAxRqlNp1c2LgHr7weriCzMhD8COOYsk
93VjZ/Az4VSkRGbmGyL+lFk9VEzhPpypE4JzPHG1+lYT8T0eyd8s1RLwaOjJ66gW
6WSvVgcb/jgu2m30gClcx8ZSOwSXDgG7aDyo6oMwUucoF3zNwJvG9q99Q0PI4Z8M
gfBighuQaGZWATNWRuJyA6ef6VkXto4IuYPnzlSs1DA+7gSS3tSg2plp1/Xuykt2
1RvKkiI2sFqs2X8Z3uVDwNLofvGrvdiSrMiRraWwaiyvA0nlaryR7qx8FOYbOZhK
wJB4CPu0hGCd+tah2/wfvwGCcN9vCNXrxH4vzBOkmd2wxfBVfJWopDvh1sqg+DsW
zn9ohbu/Cjr1h4EVwxlsm3oFaFTG6JrxIy02bj2V4NycM20tfy1D0mi0bBlrzaYB
w7Qs8PBZbEHodt8gy7m5VNWB/y0q2AnlTbLiYVrVIZ/YEc/vCPjMcX30D9Q+SGEB
igPIEJDBcy+xWy04IuIg
=vPcr
-----END PGP SIGNATURE-----

--BiOdgKC1QB4OaMKo6JHuvhfGFbdlLLEjN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

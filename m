Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D54C6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:22:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id py6so5362917pab.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 10:22:44 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o9si3747097pgc.284.2016.10.26.10.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 10:22:43 -0700 (PDT)
Message-ID: <1477502561.2431.2.camel@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH 27/27] igb: Revert "igb:
 Revert support for build_skb in igb"
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 26 Oct 2016 10:22:41 -0700
In-Reply-To: <20161025153911.4815.45366.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
	 <20161025153911.4815.45366.stgit@ahduyck-blue-test.jf.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wex7WfIy8s6ac7Ui8G+1"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com


--=-wex7WfIy8s6ac7Ui8G+1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-10-25 at 11:39 -0400, Alexander Duyck wrote:
> This reverts commit f9d40f6a9921 ("igb: Revert support for build_skb in
> igb") and adds a few changes to update it to work with the latest version
> of igb. We are now able to revert the removal of this due to the fact
> that with the recent changes to the page count and the use of
> DMA_ATTR_SKIP_CPU_SYNC we can make the pages writable so we should not be
> invalidating the additional data added when we call build_skb.
>=20
> The biggest risk with this change is that we are now not able to support
> full jumbo frames when using build_skb.=C2=A0 Instead we can only support=
 up
> to
> 2K minus the skb overhead and padding offset.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-wex7WfIy8s6ac7Ui8G+1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYEOZhAAoJEOVv75VaS+3O1Z4P/3uP7RW04IQailTXeebXSC9w
osoxi2WMndGEiu6REpQbeJreVxozinrl6RF2+7+UUTVXZQxP1MO/XIJZPFaL/WGS
OfvM1SUb0Ej6tjLfNSt8DGmRiH1a/OH37bfMwmu9+On3myoszZ2BkF19jcKRMGGp
+tWgfwh37VJlTbJtFcTggrgery1nPNmfSeX6qbv/OoThatzP3U011vYOwVFj7+Z9
PmA275pxKEUEt8uuoUZDAtOzLxNvje2XcXhnkSfClORDOSbOvWLzwLpy3l8A52gt
TropL1WH4Gj/cLfPXLv2JGq/cnCFG0+WzEp8/ysxCIa/EAACPle5YPJEgDawAXV3
jhTP6GAXZIaEeS/bqOvon0tBf1tTTjk8Hb4on/UXcxS9AjvMVpKh7QFhTDubhYMS
0q/WPWE1OXFNF7PJpX81E59CzYeXX6RdAPbvuB+jiFdX+rnlZGoHuhX8wvewNAHr
P4QT0cJ91z98FVDuTWRer+XC0eWAO3t9hhy5xUQC9KS0XmQH7x6h1bxH8dyZAXTP
N4YMGOUpfqFSVLZZHX6lcT3LYlG1QFx1IhTv1jltZJ9bymIAQdPUT/ti7TNjFfLK
qJjBxCk/bj/Rdjgg/MHlSAoJPKyr0huINvebx2UERVyH815m7XmcIqlbikeUJivl
min/nOpPIkRxNkNW8Trt
=0Bmz
-----END PGP SIGNATURE-----

--=-wex7WfIy8s6ac7Ui8G+1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

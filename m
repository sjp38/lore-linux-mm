Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6576B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 14:27:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b204so140515qkc.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 11:27:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t5si607735ywf.160.2016.09.15.11.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 11:27:37 -0700 (PDT)
Message-ID: <1473964054.10218.91.camel@redhat.com>
Subject: Re: [PATCH 1/2] mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
From: Rik van Riel <riel@redhat.com>
Date: Thu, 15 Sep 2016 14:27:34 -0400
In-Reply-To: <1473961304-19370-2-git-send-email-aarcange@redhat.com>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
	 <1473961304-19370-2-git-send-email-aarcange@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-600NoOkgfqzxRXbjgfBS"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>


--=-600NoOkgfqzxRXbjgfBS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-09-15 at 19:41 +0200, Andrea Arcangeli wrote:
> vma->vm_page_prot is read lockless from the rmap_walk, it may be
> updated concurrently and this prevents the risk of reading
> intermediate values.
>=20
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed

--=-600NoOkgfqzxRXbjgfBS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX2ugWAAoJEM553pKExN6D9+QH/jVO8GfThcLAxZC1b9nuJ6fe
Efpp78dzJ3DwjyrhQ1/TDI/Bf6cpjv4nJ6mdA1JSAPyPacP94G+sttaC5NT3I4Pg
YYeAF8yqv9YFmQwa+fBjKSooyWwpEuEpG3tUzQ72c1oM0WuF6IJwL7s/9bhfup5H
Nz9fQkcHeFcMd7BSuXmHe4lb1B+qlZpFnRSRyvtEjb/r/24SFcDzQxnxFfJ/gaY1
yFrpVD/X66TyPjeOT/xF06JHsNQTyVTAM+vAg/POYxwQFzHxnu1dTcHbRhtgcszF
slCHXasfYa3ax4L93OzrPVjreK2X0Ze9JSekVeVltaoGrO5+e/uesD+KNMMbCOI=
=0Qkl
-----END PGP SIGNATURE-----

--=-600NoOkgfqzxRXbjgfBS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

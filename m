Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5896B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 18:15:19 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id w104so166934111qge.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 15:15:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d2si23662195qkb.17.2016.03.14.15.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 15:15:02 -0700 (PDT)
Message-ID: <1457993696.8898.16.camel@redhat.com>
Subject: Re: [PATCH v3 1/2] mm, vmstat: calculate particular vm event
From: Rik van Riel <riel@redhat.com>
Date: Mon, 14 Mar 2016 18:14:56 -0400
In-Reply-To: <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/Ds/25WZbDU9XYL1B/XG"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com


--=-/Ds/25WZbDU9XYL1B/XG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-03-14 at 23:40 +0200, Ebru Akagunduz wrote:
> Currently, vmstat can calculate specific vm event with
> all_vm_events()
> however it allocates all vm events to stack. This patch introduces
> a helper to sum value of a specific vm event over all cpu, without
> loading all the events.
>=20
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-/Ds/25WZbDU9XYL1B/XG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJW5zfgAAoJEM553pKExN6DLikH/RYqlBhA8+BxAd9Wb7nAPud2
NnN/7AiCFtWgQQi/h6aZbG4X6T0mqshxowZRhOeJgM6WQqxvR8E+NoYW+YdFsTLd
8MNX3i+gsQWSqDBKjHGBEJxw9efwy8mQqxahec3gVKn8kTxZ9uX1LaXUDB61YR87
drXHw+B8Q7BvPHrhSfUHFzOkTXlWP867jp13WhX6M6JJxunkxfH6yLSP3zYl608f
hGh0KUV8rZ1w5gaF0X7ozDgrSVfwzAnwW+prwEeHsW9/EB1PXFQkuB8gtLSCt7pp
MFfCV3o2RXVkY5OF89S8ph1Z4WpM0+QBdsiaZL1g2MjzfNdIO0VFIVksMJyS+ro=
=S6HP
-----END PGP SIGNATURE-----

--=-/Ds/25WZbDU9XYL1B/XG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

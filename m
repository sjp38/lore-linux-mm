Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BBB046B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 08:55:55 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so3658369pdj.1
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 05:55:55 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id qh6si7889425pbb.154.2013.12.21.05.55.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Dec 2013 05:55:54 -0800 (PST)
Date: Sun, 22 Dec 2013 00:43:55 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v3 02/14] mm, hugetlb: region manipulation functions take
 resv_map rather list_head
Message-ID: <20131221134355.GA12407@voom.fritz.box>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Content-Disposition: inline
In-Reply-To: <1387349640-8071-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 18, 2013 at 03:53:48PM +0900, Joonsoo Kim wrote:
> To change a protection method for region tracking to find grained one,
> we pass the resv_map, instead of list_head, to region manipulation
> functions. This doesn't introduce any functional change, and it is just
> for preparing a next step.
>=20
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--DocE+STaALJfprDB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJStZsbAAoJEGw4ysog2bOS9PcQAI9nfhpAOn9DmhrqDkuAstNt
g7WyzXBgqrwePCSB/0llVIT8ZxI0cdfL3GX3ogkkwLVMcRiEX6MTR4yYoVjVX6EN
ZNdAN78D+A77soDBFpDI4+1SKYAwG8S2E94L+eceq75nzGrZ9iykw+CqcLuSagOl
WthYxjzoxPOdGF1rmMEsLZM32BFp/cHcEnNZAGBrylivb5yOm9RWvBhkBUUZO4dQ
xQva/kHP4MzP9ktC7njHNO/TwiGmK9Wln4Kqcf+IyT6PH5G6IVCcaXMQFHvr6ZqW
QJ6bqOBwT4V6FKE8TbDZ0NxwR0sNB26kR+nRkePyzsYNfKbuTV63P9noN3MzmypD
ZMLo7773qUmUWw7sTux6fddr3zsZyzxUlnxKEI/PajBJ6pczAHQnBJcKDnTU2Ivd
MEkBa8swsdggldrZP1VEfEGCIbJr8zvRjJCGtpGyvu1Ot/eDasyIPFSsVD9Np8PL
PsYHS3SIBjH4ZlBZziEqcZPkG8xuu3hwCvuUlHltV3QGuzWANVwqC3wM3DpwixZp
MVKeIz5HJJinYyKUx9SS0i4k8tHUEHgYkUSQqrf/bSlQYGn+O+ZnepbcJ3wazVee
FhGKtm9rjus2/YEB3hRDuIKqpacpcmaKDH1lg1P8dTqZns76jCvs4d0ttAig3itp
URAzCzZEBcXf9Vf0md/S
=LC9f
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

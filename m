Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 097486B6AA0
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:59:15 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b26so14404401qtq.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:59:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l2si8884820qvo.45.2018.12.03.10.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 10:59:14 -0800 (PST)
Message-ID: <e295bca26fce6408c7265292e81107b04a1a144d.camel@redhat.com>
Subject: Re: [PATCH V2] mm: Replace all open encodings for NUMA_NO_NODE
From: Doug Ledford <dledford@redhat.com>
Date: Mon, 03 Dec 2018 13:59:08 -0500
In-Reply-To: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
References: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Jgd362xHNNmppwzCQCK+"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl, vkoul@kernel.org


--=-Jgd362xHNNmppwzCQCK+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-11-26 at 17:56 +0530, Anshuman Khandual wrote:
> At present there are multiple places where invalid node number is encoded
> as -1. Even though implicitly understood it is always better to have macr=
os
> in there. Replace these open encodings for an invalid node number with th=
e
> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions lik=
e
> 'invalid node' from various places redirecting them to a common definitio=
n.
>=20
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Changes in V2:
>=20
> - Added inclusion of 'numa.h' header at various places per Andrew
> - Updated 'dev_to_node' to use NUMA_NO_NODE instead per Vinod
>=20
> Changes in V1: (https://lkml.org/lkml/2018/11/23/485)
>=20
> - Dropped OCFS2 changes per Joseph
> - Dropped media/video drivers changes per Hans
>=20
> RFC - https://patchwork.kernel.org/patch/10678035/
>=20
> Build tested this with multiple cross compiler options like alpha, sparc,
> arm64, x86, powerpc, powerpc64le etc with their default config which migh=
t
> not have compiled tested all driver related changes. I will appreciate
> folks giving this a test in their respective build environment.
>=20
> All these places for replacement were found by running the following grep
> patterns on the entire kernel code. Please let me know if this might have
> missed some instances. This might also have replaced some false positives=
.
> I will appreciate suggestions, inputs and review.
>=20
> 1. git grep "nid =3D=3D -1"
> 2. git grep "node =3D=3D -1"
> 3. git grep "nid =3D -1"
> 4. git grep "node =3D -1"
>=20
>  drivers/infiniband/hw/hfi1/affinity.c         |  3 ++-
>  drivers/infiniband/hw/hfi1/init.c             |  3 ++-

For the drivers/infiniband changes,

Acked-by: Doug Ledford <dledford@redhat.com>

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-Jgd362xHNNmppwzCQCK+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlwFfPwACgkQuCajMw5X
L911nA/+Pq4noh4r/S3RhvajccFUfwzT5+IhZ7V69GHF9EaiPK8E1lka1m7BdNtX
MlRVfjw6oW1Gs5uQFJfJC2qucbFLzZOm1I25GgzLq/iEq0ItnvUBVC13P2W5bmIa
OB1zY9MRcBQs3T9W3/rcwFwxzYBIh9YsFNbq+op5uu5iUnKsLYenyPPTnWSVj5qO
PWFKzPVxp68NmPpc/vPph6SrazSdSChuZFH06PElH0ifHC+Gde6gCuBSiX4dNCm5
NzODtQz2AqmWPLS7XrgwtN2VGdjN8sPpQBcaYMV9aYOXzXdn5BexsgtoSd5VHdUN
UZOUZQi/1UwA/i+Ngg86mv7nKWh/sxflS7a+F3u3xR9BoP09Gtt41Yu+zLZ28omr
NTKrHWhoiv+WFY+iXoCCtPbI8TYjTuqyVhqHOZiMzX9rTxYBZ3wtHMOqmdQl5K69
nnpJpIJr0uFEehieZvo7Tcvj28D7kDUwYN66HkEJcie71Uu45+lW2HoaIQwURsnY
ot6h/yf8X2Pu1PY4A9FjXeFbECh4qXjZXevOz6vDaubqVwWtQdpoGl78KPd8WaJ+
8tCtiT+L99uUE6sZoLaTdYd/EYsABxfbduwcTOdpNWVgxx2bxDXSgWkAd1bk0A0k
zFoViov/qfs5E2JiGmVcxPeya+X/5gFMM8vJRwIvhMyokGfWRLg=
=LheN
-----END PGP SIGNATURE-----

--=-Jgd362xHNNmppwzCQCK+--

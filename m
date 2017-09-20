Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 221846B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:56:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m103so4899511iod.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:56:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s132si904434oif.303.2017.09.20.08.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 08:56:00 -0700 (PDT)
Subject: Re: [Qemu-devel] [PATCH] virtio_balloon: include buffers and chached
 memory statistics
References: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>
From: Eric Blake <eblake@redhat.com>
Message-ID: <2735dd8d-4854-0437-161e-327c00119a5a@redhat.com>
Date: Wed, 20 Sep 2017 10:55:45 -0500
MIME-Version: 1.0
In-Reply-To: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="3VDsawmRpSEKiXot6oFM78jLv1e8Io5wF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Huang Ying <ying.huang@intel.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3VDsawmRpSEKiXot6oFM78jLv1e8Io5wF
Content-Type: multipart/mixed; boundary="U30IMBX2MqwrKfA1iBW2eq2CKqNEdJC8G";
 protected-headers="v1"
From: Eric Blake <eblake@redhat.com>
To: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>,
 linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org,
 kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
 Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>,
 Huang Ying <ying.huang@intel.com>
Message-ID: <2735dd8d-4854-0437-161e-327c00119a5a@redhat.com>
Subject: Re: [Qemu-devel] [PATCH] virtio_balloon: include buffers and chached
 memory statistics
References: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>
In-Reply-To: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>

--U30IMBX2MqwrKfA1iBW2eq2CKqNEdJC8G
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 09/20/2017 10:48 AM, Tom=C3=A1=C5=A1 Golembiovsk=C3=BD wrote:

In the subject: s/chached/cached/

> Add a new fields, VIRTIO_BALLOON_S_BUFFERS and VIRTIO_BALLOON_S_CACHED,=

> to virtio_balloon memory statistics protocol. The values correspond to
> 'Buffers' and 'Cached' in /proc/meminfo.
>=20
> To be able to compute the value of 'Cached' memory it is necessary to
> export total_swapcache_pages() to modules.
>=20
> Signed-off-by: Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 11 +++++++++++
>  include/uapi/linux/virtio_balloon.h |  4 +++-
>  mm/swap_state.c                     |  1 +
>  3 files changed, 15 insertions(+), 1 deletion(-)
>=20


--=20
Eric Blake, Principal Software Engineer
Red Hat, Inc.           +1-919-301-3266
Virtualization:  qemu.org | libvirt.org


--U30IMBX2MqwrKfA1iBW2eq2CKqNEdJC8G--

--3VDsawmRpSEKiXot6oFM78jLv1e8Io5wF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: Public key at http://people.redhat.com/eblake/eblake.gpg
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEzBAEBCAAdFiEEccLMIrHEYCkn0vOqp6FrSiUnQ2oFAlnCj4EACgkQp6FrSiUn
Q2qYHQf/epFcqf51mAzcUw1TegHyasbJ/HdLsRrkNLmKP7qTQwDTybhxa98vcxqU
hajKbOh9y4bd11V+WpbZiJCusB1oLcO3vAW8VLCTF16GNDEvxUlXcBCxNgkFW6AD
f8DOwKkz3JNJVXAJOtq0LhH1To30utL+3vnYPI8x1kskXQaukL+wkbBG2Sf7hT2L
/bhBs55QZQ6MdrYeF5cEsHfReKIc4my/IKr2kuBwJzV8OHMOX/KrSFYqAo/r3aWr
MAfRYtvA3nSF9PyZyl886ArIDxhnkUzmwLG6zSPTmMrLpF1MZyYnCQXigFazm2vr
/BtmbxLCB8jEx9Zfq5EU4uQQotCWCQ==
=SZUr
-----END PGP SIGNATURE-----

--3VDsawmRpSEKiXot6oFM78jLv1e8Io5wF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

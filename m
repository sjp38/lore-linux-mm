Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90E7E6B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 09:06:25 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y42so5923843wrd.23
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 06:06:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor6242002edi.43.2017.11.20.06.06.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 06:06:23 -0800 (PST)
Date: Mon, 20 Nov 2017 15:06:19 +0100
From: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>
Subject: Re: [PATCH v3] virtio_balloon: include disk/file caches memory
 statistics
Message-ID: <20171120150619.456c56f0@fiorina>
In-Reply-To: <2e8c12f5242bcf755a33ee3a0e9ef94339d1808c.1510487579.git.tgolembi@redhat.com>
References: <2e8c12f5242bcf755a33ee3a0e9ef94339d1808c.1510487579.git.tgolembi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
Cc: Huang Ying <ying.huang@intel.com>, Gal Hammer <ghammer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Amnon Ilan <ailan@redhat.com>, Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@redhat.com>

On Sun, 12 Nov 2017 13:05:38 +0100
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com> wrote:

> Add a new field VIRTIO_BALLOON_S_CACHES to virtio_balloon memory
> statistics protocol. The value represents all disk/file caches.
>=20
> In this case it corresponds to the sum of values
> Buffers+Cached+SwapCached from /proc/meminfo.
>=20
> Signed-off-by: Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 4 ++++
>  include/uapi/linux/virtio_balloon.h | 3 ++-
>  2 files changed, 6 insertions(+), 1 deletion(-)
>=20
=20
ping


--=20
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

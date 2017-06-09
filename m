Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 255AE6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 07:18:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n81so24054019pfb.14
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 04:18:47 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s61si766977plb.32.2017.06.09.04.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 04:18:46 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v11 0/6] Virtio-balloon Enhancement
Date: Fri, 9 Jun 2017 11:18:42 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73925B11D@shsmsx102.ccr.corp.intel.com>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

On Friday, June 9, 2017 6:42 PM, Wang, Wei W wrote:
> To: virtio-dev@lists.oasis-open.org; linux-kernel@vger.kernel.org; qemu-
> devel@nongnu.org; virtualization@lists.linux-foundation.org;
> kvm@vger.kernel.org; linux-mm@kvack.org; mst@redhat.com;
> david@redhat.com; Hansen, Dave <dave.hansen@intel.com>;
> cornelia.huck@de.ibm.com; akpm@linux-foundation.org;
> mgorman@techsingularity.net; aarcange@redhat.com; amit.shah@redhat.com;
> pbonzini@redhat.com; Wang, Wei W <wei.w.wang@intel.com>;
> liliang.opensource@gmail.com
> Subject: [PATCH v11 0/6] Virtio-balloon Enhancement
>=20
> This patch series enhances the existing virtio-balloon with the following=
 new
> features:
> 1) fast ballooning: transfer ballooned pages between the guest and host i=
n
> chunks, instead of one by one; and
> 2) cmdq: a new virtqueue to send commands between the device and driver.
> Currently, it supports commands to report memory stats (replace the old s=
tatq
> mechanism) and report guest unused pages.

v10->v11 changes:
1) virtio_balloon: use vring_desc to describe a chunk;
2) virtio_ring: support to add an indirect desc table to virtqueue;
3)  virtio_balloon: use cmdq to report guest memory statistics.

>=20
> Liang Li (1):
>   virtio-balloon: deflate via a page list
>=20
> Wei Wang (5):
>   virtio-balloon: coding format cleanup
>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
>   mm: function to offer a page block on the free list
>   mm: export symbol of next_zone and first_online_pgdat
>   virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
>=20
>  drivers/virtio/virtio_balloon.c     | 781 ++++++++++++++++++++++++++++++=
++--
> --
>  drivers/virtio/virtio_ring.c        | 120 +++++-
>  include/linux/mm.h                  |   5 +
>  include/linux/virtio.h              |   7 +
>  include/uapi/linux/virtio_balloon.h |  14 +
>  include/uapi/linux/virtio_ring.h    |   3 +
>  mm/mmzone.c                         |   2 +
>  mm/page_alloc.c                     |  91 +++++
>  8 files changed, 950 insertions(+), 73 deletions(-)
>=20
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

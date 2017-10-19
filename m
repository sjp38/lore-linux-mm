Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD1A6B0268
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:33:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n4so3969652wrb.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:33:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t66sor368659wme.35.2017.10.19.05.33.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 05:33:31 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:33:25 +0200
From: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>
Subject: Re: [PATCH v2 0/1] linux: Buffers/caches in VirtIO Balloon driver
 stats
Message-ID: <20171019143325.12b6b8aa@fiorina>
In-Reply-To: <20171005155118.51a5bea3@fiorina>
References: <cover.1505998455.git.tgolembi@redhat.com>
	<20171005155118.51a5bea3@fiorina>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org
Cc: Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Huang Ying <ying.huang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>

On Thu, 5 Oct 2017 15:51:18 +0200
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com> wrote:

> On Thu, 21 Sep 2017 14:55:40 +0200
> Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com> wrote:
>=20
> > Linux driver part
> >=20
> > v2:
> > - fixed typos
> >=20
> > Tom=C3=A1=C5=A1 Golembiovsk=C3=BD (1):
> >   virtio_balloon: include buffers and cached memory statistics
> >=20
> >  drivers/virtio/virtio_balloon.c     | 11 +++++++++++
> >  include/uapi/linux/virtio_balloon.h |  4 +++-
> >  mm/swap_state.c                     |  1 +
> >  3 files changed, 15 insertions(+), 1 deletion(-)
> >=20
> > --=20
> > 2.14.1
> >=20
>=20
> ping

ping

--=20
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

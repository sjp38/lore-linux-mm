Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E71516B06D5
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 11:23:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c14so17102874pgn.11
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 08:23:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f10si14871903pgr.808.2017.08.03.08.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 08:23:11 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH] MAINTAINERS: copy virtio on balloon_compaction.c
Date: Thu, 3 Aug 2017 15:23:06 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73928C9A1@shsmsx102.ccr.corp.intel.com>
References: <1501764010-24456-1-git-send-email-mst@redhat.com>
 <20170803133622.GD26205@xps>
In-Reply-To: <20170803133622.GD26205@xps>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "zhenwei.pi@youruncloud.com" <zhenwei.pi@youruncloud.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>

On Thursday, August 3, 2017 9:36 PM, Rafael Aquini wrote:
> On Thu, Aug 03, 2017 at 03:42:52PM +0300, Michael S. Tsirkin wrote:
> > Changes to mm/balloon_compaction.c can easily break virtio, and virtio
> > is the only user of that interface.  Add a line to MAINTAINERS so
> > whoever changes that file remembers to copy us.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  MAINTAINERS | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/MAINTAINERS b/MAINTAINERS index f66488d..6b1d60e 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -13996,6 +13996,7 @@ F:	drivers/block/virtio_blk.c
> >  F:	include/linux/virtio*.h
> >  F:	include/uapi/linux/virtio_*.h
> >  F:	drivers/crypto/virtio/
> > +F:	mm/balloon_compaction.c
> >
> >  VIRTIO CRYPTO DRIVER
> >  M:	Gonglei <arei.gonglei@huawei.com>
> > --
> > MST
>=20
> Acked-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Wei Wang <wei.w.wang@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

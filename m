Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9E75C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F51922DBF
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UrywvA9V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F51922DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DC366B0003; Wed,  4 Sep 2019 10:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28D166B0006; Wed,  4 Sep 2019 10:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9866B0007; Wed,  4 Sep 2019 10:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id F0E066B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:23:27 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 94A598768
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:23:27 +0000 (UTC)
X-FDA: 75897456054.12.cloud99_108a257f4817
X-HE-Tag: cloud99_108a257f4817
X-Filterd-Recvd-Size: 11942
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:23:26 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id s21so44639218ioa.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 07:23:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SD6S9qMSdEaKb7A47HNQkeSQYOe/PbBwHeji7l9BPq0=;
        b=UrywvA9VgH65G9YFybvuUU60d5BHxhw+Y13cHePdKBNfxviMxlavUpDIYjMEqpnWaR
         3qrN1NZ37Q+7IlbSebRQjChVkKmh5/Hq+NAAqsRxFZU67O/3Bp8U8HYkb5omMWOFYdXA
         D0sECjTa4NM4EBDFZV09H9ZrxkUJp2IotDOFfRtzUs+t58sj2nLCbFVRbzlOAF83XHUv
         Cjd2kF0JSQjhW4dcFBRb/PpivgyE2G0IVAfBM+aPlAxGKx5ex6Gev+S4pfLzyC4ny/H1
         uUcnw1DqgoQ5qd7jyHMtBpUPO8JfVfZwMJYWBTdGgigB8fXDNVm0hKkwPgGvjuyZtxJM
         7sag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=SD6S9qMSdEaKb7A47HNQkeSQYOe/PbBwHeji7l9BPq0=;
        b=B3moo8j4iFR4p0mwFqYC6dUG6/qH3v3ZvVbO3eI36WysrJStvY1jFGkKg+unRu0bgT
         g79/gCZz7rXOMJ20WsOKxYp2yqtr2SyicmOdE934wnOroLP2DQoX1EIypRHCR7hYP5sC
         63p1OkeT5XImGXmP3jsW9XPd5F6MGUaH8tCkXPy0SGMWPwghtQFqL3aq5gIdb/Znr7ve
         Q3qL0HTJ5H2+LpyoTErtY/hgELrrG2FAu/xz2+r8sVlx5OleoUnGdq6aFEOMNE62I1+l
         CjFW3A01ZmFkHirx7krjBh7r533674Y+p3zVeM3LAZYWaiRk+97+IIi39wcuNICnbCZ/
         uD4w==
X-Gm-Message-State: APjAAAWcoqsFIkB3Gh60y9Z2j2adflq/nLxpIrGJAEwMfBD//6aP5DrF
	Ah/WeY/KyQKepLWYVad5Z6OMruIADXqzpXi9d7s=
X-Google-Smtp-Source: APXvYqy3U9zx4jW57pjNOKNx8WUkW1Wy6QQaV1f3ESKS5WvNx2ZxOKuVaesrDcJ6nGSM16g3C2KoEUSBXcMUrWmIKrU=
X-Received: by 2002:a5d:8f86:: with SMTP id l6mr1610473iol.270.1567607006137;
 Wed, 04 Sep 2019 07:23:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
 <20190812213356.22097.20751.stgit@localhost.localdomain> <20190903032759-mutt-send-email-mst@kernel.org>
 <CAKgT0UfFU3oT5kKZk999XfrM6oducTizcUL5xpDWmMG=oP04ow@mail.gmail.com> <20190904064226-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190904064226-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 4 Sep 2019 07:23:14 -0700
Message-ID: <CAKgT0UdFs2VmVZgoho98=qVPJL1z9rvWv5G6VbxCfgVTJkmeYg@mail.gmail.com>
Subject: Re: [PATCH v5 6/6] virtio-balloon: Add support for providing unused
 page reports to host
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 3:44 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Tue, Sep 03, 2019 at 07:13:32AM -0700, Alexander Duyck wrote:
> > On Tue, Sep 3, 2019 at 12:32 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > On Mon, Aug 12, 2019 at 02:33:56PM -0700, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > >
> > > > Add support for the page reporting feature provided by virtio-balloon.
> > > > Reporting differs from the regular balloon functionality in that is is
> > > > much less durable than a standard memory balloon. Instead of creating a
> > > > list of pages that cannot be accessed the pages are only inaccessible
> > > > while they are being indicated to the virtio interface. Once the
> > > > interface has acknowledged them they are placed back into their respective
> > > > free lists and are once again accessible by the guest system.
> > > >
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > ---
> > > >  drivers/virtio/Kconfig              |    1 +
> > > >  drivers/virtio/virtio_balloon.c     |   65 +++++++++++++++++++++++++++++++++++
> > > >  include/uapi/linux/virtio_balloon.h |    1 +
> > > >  3 files changed, 67 insertions(+)
> > > >
> > > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > > index 078615cf2afc..4b2dd8259ff5 100644
> > > > --- a/drivers/virtio/Kconfig
> > > > +++ b/drivers/virtio/Kconfig
> > > > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> > > >       tristate "Virtio balloon driver"
> > > >       depends on VIRTIO
> > > >       select MEMORY_BALLOON
> > > > +     select PAGE_REPORTING
> > > >       ---help---
> > > >        This driver supports increasing and decreasing the amount
> > > >        of memory within a KVM guest.
> > > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > > index 2c19457ab573..52f9eeda1877 100644
> > > > --- a/drivers/virtio/virtio_balloon.c
> > > > +++ b/drivers/virtio/virtio_balloon.c
> > > > @@ -19,6 +19,7 @@
> > > >  #include <linux/mount.h>
> > > >  #include <linux/magic.h>
> > > >  #include <linux/pseudo_fs.h>
> > > > +#include <linux/page_reporting.h>
> > > >
> > > >  /*
> > > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > > @@ -37,6 +38,9 @@
> > > >  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
> > > >       (1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> > > >
> > > > +/*  limit on the number of pages that can be on the reporting vq */
> > > > +#define VIRTIO_BALLOON_VRING_HINTS_MAX       16
> > > > +
> > > >  #ifdef CONFIG_BALLOON_COMPACTION
> > > >  static struct vfsmount *balloon_mnt;
> > > >  #endif
> > > > @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
> > > >       VIRTIO_BALLOON_VQ_DEFLATE,
> > > >       VIRTIO_BALLOON_VQ_STATS,
> > > >       VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > > +     VIRTIO_BALLOON_VQ_REPORTING,
> > > >       VIRTIO_BALLOON_VQ_MAX
> > > >  };
> > > >
> > > > @@ -113,6 +118,10 @@ struct virtio_balloon {
> > > >
> > > >       /* To register a shrinker to shrink memory upon memory pressure */
> > > >       struct shrinker shrinker;
> > > > +
> > > > +     /* Unused page reporting device */
> > > > +     struct virtqueue *reporting_vq;
> > > > +     struct page_reporting_dev_info ph_dev_info;
> > > >  };
> > > >
> > > >  static struct virtio_device_id id_table[] = {
> > > > @@ -152,6 +161,32 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > > >
> > > >  }
> > > >
> > > > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > > > +                                 unsigned int nents)
> > > > +{
> > > > +     struct virtio_balloon *vb =
> > > > +             container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > > > +     struct virtqueue *vq = vb->reporting_vq;
> > > > +     unsigned int unused, err;
> > > > +
> > > > +     /* We should always be able to add these buffers to an empty queue. */
> > > > +     err = virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > > > +                               GFP_NOWAIT | __GFP_NOWARN);
> > > > +
> > > > +     /*
> > > > +      * In the extremely unlikely case that something has changed and we
> > > > +      * are able to trigger an error we will simply display a warning
> > > > +      * and exit without actually processing the pages.
> > > > +      */
> > > > +     if (WARN_ON(err))
> > > > +             return;
> > > > +
> > > > +     virtqueue_kick(vq);
> > > > +
> > > > +     /* When host has read buffer, this completes via balloon_ack */
> > > > +     wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > > > +}
> > > > +
> > > >  static void set_page_pfns(struct virtio_balloon *vb,
> > > >                         __virtio32 pfns[], struct page *page)
> > > >  {
> > > > @@ -476,6 +511,7 @@ static int init_vqs(struct virtio_balloon *vb)
> > > >       names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> > > >       names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> > > >       names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > > > +     names[VIRTIO_BALLOON_VQ_REPORTING] = NULL;
> > > >
> > > >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > >               names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > > > @@ -487,11 +523,19 @@ static int init_vqs(struct virtio_balloon *vb)
> > > >               callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > > >       }
> > > >
> > > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> > > > +             names[VIRTIO_BALLOON_VQ_REPORTING] = "reporting_vq";
> > > > +             callbacks[VIRTIO_BALLOON_VQ_REPORTING] = balloon_ack;
> > > > +     }
> > > > +
> > > >       err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> > > >                                        vqs, callbacks, names, NULL, NULL);
> > > >       if (err)
> > > >               return err;
> > > >
> > > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
> > > > +             vb->reporting_vq = vqs[VIRTIO_BALLOON_VQ_REPORTING];
> > > > +
> > > >       vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> > > >       vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> > > >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > > @@ -931,12 +975,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
> > > >               if (err)
> > > >                       goto out_del_balloon_wq;
> > > >       }
> > > > +
> > > > +     vb->ph_dev_info.report = virtballoon_unused_page_report;
> > > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> > > > +             unsigned int capacity;
> > > > +
> > > > +             capacity = min_t(unsigned int,
> > > > +                              virtqueue_get_vring_size(vb->reporting_vq) - 1,
> > > > +                              VIRTIO_BALLOON_VRING_HINTS_MAX);
> > >
> > > Hmm why - 1 exactly?
> > > This might end up being 0 in the unusual configuration of vq size 1.
> > > Also, VIRTIO_BALLOON_VRING_HINTS_MAX is a power of 2 but
> > > virtqueue_get_vring_size(vb->reporting_vq) - 1 won't
> > > be if we are using split rings - donnu if that matters.
> >
> > Is a vq size of 1 valid?
> > Does that mean you can use that 1 descriptor?
>
> It seems to be according to the spec, and linux seems to accept that
> without issues, and only put 1 descriptor there.
>
> > Odds are I probably misunderstood the ring config in the other hinting
> > implementation. Looking it over now I guess it was adding one
> > additional entry for a command header and that was why it was
> > reserving one additional slot. I can update the code to drop the "- 1"
> > if the ring is capable of being fully utilized.
> >
> > Thanks.
> >
> > - Alex
>
> It should be. I just hacked qemu to have 1 descriptor sized ring
> and everything seems to work.

Okay. I will update the code to make the capacity equal to the vring
size and max out oat HINTS_MAX.

I also have a fix that will make sure we return an error if we attempt
to enable the page hinting with a capacity of 0 just in case.

I'll post the updated v7 later today.

Thanks.

- Alex


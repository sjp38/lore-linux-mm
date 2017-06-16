Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 033D283292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:04:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z5so37222889qta.12
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:04:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 12si2232645qtq.325.2017.06.16.08.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 08:04:14 -0700 (PDT)
Date: Fri, 16 Jun 2017 18:04:06 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] virtio-mem: paravirtualized memory
Message-ID: <20170616175748-mutt-send-email-mst@kernel.org>
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jun 16, 2017 at 04:20:02PM +0200, David Hildenbrand wrote:
> Hi,
> 
> this is an idea that is based on Andrea Arcangeli's original idea to
> host enforce guest access to memory given up using virtio-balloon using
> userfaultfd in the hypervisor. While looking into the details, I
> realized that host-enforcing virtio-balloon would result in way too many
> problems (mainly backwards compatibility) and would also have some
> conceptual restrictions that I want to avoid. So I developed the idea of
> virtio-mem - "paravirtualized memory".

Thanks! I went over this quickly, will read some more in the
coming days. I would like to ask for some clarifications
on one part meanwhile:

> Q: Why not reuse virtio-balloon?
> 
> A: virtio-balloon is for cooperative memory management. It has a fixed
>    page size

We are fixing that with VIRTIO_BALLOON_F_PAGE_CHUNKS btw.
I would appreciate you looking into that patchset.

> and will deflate in certain situations.

What does this refer to?

> Any change we
>    introduce will break backwards compatibility.

Why does this have to be the case?

> virtio-balloon was not
>    designed to give guarantees. Nobody can hinder the guest from
>    deflating/reusing inflated memory.

Reusing without deflate is forbidden with TELL_HOST, right?

>    In addition, it might make perfect
>    sense to have both, virtio-balloon and virtio-mem at the same time,
>    especially looking at the DEFLATE_ON_OOM or STATS features of
>    virtio-balloon. While virtio-mem is all about guarantees, virtio-
>    balloon is about cooperation.

Thanks, and I intend to look more into this next week.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

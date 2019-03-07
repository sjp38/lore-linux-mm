Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94B26C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43B4F20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43B4F20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8E5B8E0003; Thu,  7 Mar 2019 14:16:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3BC98E0002; Thu,  7 Mar 2019 14:16:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A05808E0003; Thu,  7 Mar 2019 14:16:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76A4B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:16:30 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v67so13914239qkl.22
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:16:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5yC8khztCArbAH4cSGl3WRQb/A8z7eQuPPyNhOS2zEA=;
        b=OCJRO9T22TgW/hV3TqBm2qlqDE40HZ+6qEXs0NOdad3PKCZqftW8kdIN3LoyqpRpcR
         +NGWsdIMxVXBw8na8vYij7TAHpSkoFpUOR+02pisMjYnPjdBLCQgY70/EInHAlpcfoWY
         aXNxxQZ5aFchQT7LDi2Yj1FUsw5v9/x9YvrvqyujvqK8wd70SAB6k9FYsziEVRbvNybo
         nsLIoNuTKCdyK7/wZ30YLRAyPzd0CTomSEEmVVF6f86568PnwNHlZoepCZU8v+ljyhCV
         fqUoBesXUCGg5PV24oyeDso+1dRBkI0U1y0Dnkpx2S+08OJJZEAOCwDPh/qwltZDwYqn
         7OtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV0Z12I1P6GOtgpuqQNCupn+GJW8JOZUIGnKLezj6IikBXWYNo/
	dPtzQyEAh9+7YE2QGEMuw4R+WBXZbqw1XxJp4LFtKJd0x+95kU4z351PAhvx+37iCAujzzzN0Ru
	8KDIcF5uXp+mxsqA2LyJIV0UtCbUsUd7g8iq6y3GsMBvMld3+NzjLlfaj8FZl77vB3A==
X-Received: by 2002:a37:dd8d:: with SMTP id u13mr10542129qku.239.1551986190214;
        Thu, 07 Mar 2019 11:16:30 -0800 (PST)
X-Google-Smtp-Source: APXvYqzrXRj0a4YvW9pQ7RoRaVSV+db4Zu6O0tYq8xK9lUG+oumVrzEA/zCMsYZgrdg5f6mtwjtj
X-Received: by 2002:a37:dd8d:: with SMTP id u13mr10542071qku.239.1551986189172;
        Thu, 07 Mar 2019 11:16:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551986189; cv=none;
        d=google.com; s=arc-20160816;
        b=L5xpyFQyQkF2VCCLp3AziZwwCufYKIRYCvoJ0SXbJ8x2j2+FwDtvwHttdn6Q4tDg4T
         Dvv7bppkPoEXqDBfhvwjzfXn7qYYHffsBvRBsZX5J0mmQ5yktRH1uLlFy1flc9aPY5kd
         kgqLrsRfJwQMQUoCZc0wOAvsG4hGWl/B/o6XtH6Ud/Bcq0/yj7G6sI2CToJaNalrjPut
         i5Gdzor0q4qrwDYOrmUN1+kyoXKceFcY9g8kNBuwDZqGd4ofB64FlrYbbqjs38GMFJxi
         ewsWIrSl7Q9UkCJqk8AhaLnZOm8zqfbFfkEXbnNrHl8hk/Vijik56vmJm++9f2r1vbFA
         PYIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5yC8khztCArbAH4cSGl3WRQb/A8z7eQuPPyNhOS2zEA=;
        b=M09oAYhNUt9SCV9yKoCKKuRzCJug0BxCIbR29pFQALNnyNEstt9JkZ+zwKKJBXQjiU
         e0vu2bulDRlZiR8ap/XWFpUDciDBMfG5HBAq6MG0KwnBoXr8WQyJbw8Da6IgxXd5QzDJ
         gVDJ0LdjdY15WZsQPpX+VrS+QLexxcL77KOb9pV+YB33ABOM0Cdpf7KMggtVvoT7cTTh
         x5Xo7o7E3x661l4b01RLOno/5ND8i4qoZrbVxGxShbNqa7jLBFBz61MU1eTTuwtjSQu7
         WslbFlfO7e1Xf9kWcE730MG2HTHjtALT3jhErYyAOGieWcYEe251jmX1MjGaufsgiKE8
         +J8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si1529884qtc.289.2019.03.07.11.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:16:29 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 468B470D6A;
	Thu,  7 Mar 2019 19:16:28 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 91D892D34E;
	Thu,  7 Mar 2019 19:16:23 +0000 (UTC)
Date: Thu, 7 Mar 2019 14:16:22 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307191622.GP23850@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307124700-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 07 Mar 2019 19:16:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> > > +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> > > +	.invalidate_range = vhost_invalidate_range,
> > > +};
> > > +
> > >  void vhost_dev_init(struct vhost_dev *dev,
> > >  		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
> > >  {
> > 
> > I also wonder here: when page is write protected then
> > it does not look like .invalidate_range is invoked.
> > 
> > E.g. mm/ksm.c calls
> > 
> > mmu_notifier_invalidate_range_start and
> > mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
> > 
> > Similarly, rmap in page_mkclean_one will not call
> > mmu_notifier_invalidate_range.
> > 
> > If I'm right vhost won't get notified when page is write-protected since you
> > didn't install start/end notifiers. Note that end notifier can be called
> > with page locked, so it's not as straight-forward as just adding a call.
> > Writing into a write-protected page isn't a good idea.
> > 
> > Note that documentation says:
> > 	it is fine to delay the mmu_notifier_invalidate_range
> > 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
> > implying it's called just later.
> 
> OK I missed the fact that _end actually calls
> mmu_notifier_invalidate_range internally. So that part is fine but the
> fact that you are trying to take page lock under VQ mutex and take same
> mutex within notifier probably means it's broken for ksm and rmap at
> least since these call invalidate with lock taken.

Yes this lock inversion needs more thoughts.

> And generally, Andrea told me offline one can not take mutex under
> the notifier callback. I CC'd Andrea for why.

Yes, the problem then is the ->invalidate_page is called then under PT
lock so it cannot take mutex, you also cannot take the page_lock, it
can at most take a spinlock or trylock_page.

So it must switch back to the _start/_end methods unless you rewrite
the locking.

The difference with _start/_end, is that ->invalidate_range avoids the
_start callback basically, but to avoid the _start callback safely, it
has to be called in between the ptep_clear_flush and the set_pte_at
whenever the pfn changes like during a COW. So it cannot be coalesced
in a single TLB flush that invalidates all sptes in a range like we
prefer for performance reasons for example in KVM. It also cannot
sleep.

In short ->invalidate_range must be really fast (it shouldn't require
to send IPI to all other CPUs like KVM may require during an
invalidate_range_start) and it must not sleep, in order to prefer it
to _start/_end.

I.e. the invalidate of the secondary MMU that walks the linux
pagetables in hardware (in vhost case with GUP in software) has to
happen while the linux pagetable is zero, otherwise a concurrent
hardware pagetable lookup could re-instantiate a mapping to the old
page in between the set_pte_at and the invalidate_range_end (which
internally calls ->invalidate_range). Jerome documented it nicely in
Documentation/vm/mmu_notifier.rst .

Now you don't really walk the pagetable in hardware in vhost, but if
you use gup_fast after usemm() it's similar.

For vhost the invalidate would be really fast, there are no IPI to
deliver at all, the problem is just the mutex.

> That's a separate issue from set_page_dirty when memory is file backed.

Yes. I don't yet know why the ext4 internal __writepage cannot
re-create the bh if they've been freed by the VM and why such race
where the bh are freed for a pinned VM_SHARED ext4 page doesn't even
exist for transient pins like O_DIRECT (does it work by luck?), but
with mmu notifiers there are no long term pins anyway, so this works
normally and it's like the memory isn't pinned. In any case I think
that's a kernel bug in either __writepage or try_to_free_buffers, so I
would ignore it considering qemu will only use anon memory or tmpfs or
hugetlbfs as backing store for the virtio ring. It wouldn't make sense
for qemu to risk triggering I/O on a VM_SHARED ext4, so we shouldn't
be even exposed to what seems to be an orthogonal kernel bug.

I suppose whatever solution will fix the set_page_dirty_lock on
VM_SHARED ext4 for the other places that don't or can't use mmu
notifiers, will then work for vhost too which uses mmu notifiers and
will be less affected from the start if something.

Reading the lwn link about the discussion about the long term GUP pin
from Jan vs set_page_dirty_lock: I can only agree with the last part
where Jerome correctly pointed out at the end that mellanox RDMA got
it right by avoiding completely long term pins by using mmu notifier
and in general mmu notifier is the standard solution to avoid long
term pins. Nothing should ever take long term GUP pins, if it does it
means software is bad or the hardware lacks features to support on
demand paging. Still I don't get why transient pins like O_DIRECT
where mmu notifier would be prohibitive to use (registering into mmu
notifier cannot be done at high frequency, the locking to do so is
massive) cannot end up into the same ext4 _writepage crash as long
term pins: long term or short term transient is a subjective measure
from VM standpoint, the VM won't know the difference, luck will
instead.

> It's because of all these issues that I preferred just accessing
> userspace memory and handling faults. Unfortunately there does not
> appear to exist an API that whitelists a specific driver along the lines
> of "I checked this code for speculative info leaks, don't add barriers
> on data path please".

Yes that's unfortunate, __uaccess_begin_nospec() is now making
prohibitive to frequently access userland code.

I doubt we can do like access_ok() and only check it once. access_ok
checks the virtual address, and if the virtual address is ok doesn't
wrap around and it points to userland in a safe range, it's always
ok. There's no need to run access_ok again if we keep hitting on the
very same address.

__uaccess_begin_nospec() instead is about runtime stuff that can
change the moment copy-user has completed even before returning to
userland, so there's no easy way to do it just once.

On top of skipping the __uaccess_begin_nospec(), the mmu notifier soft
vhost design will further boost the performance by guaranteeing the
use of gigapages TLBs when available (or 2M TLBs worst case) even if
QEMU runs on smaller pages.

Thanks,
Andrea


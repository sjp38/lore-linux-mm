Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA335C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 04:40:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51DD921871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 04:40:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51DD921871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9CF46B0271; Fri, 15 Mar 2019 00:40:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D25CE6B0272; Fri, 15 Mar 2019 00:40:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BED386B0273; Fri, 15 Mar 2019 00:40:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2396B0271
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 00:40:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so7494001qtb.22
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 21:40:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=9lZt/iHfY5CFZ43vX5rjBw+OVsy+LF4uzOxN62wlTx8=;
        b=GDVzKF6RJPt+0cY74f0d1cvHNF8ALGIJ1/1JKwaM1j7SEYVlZhD5pi5Lp0xNKC3sSY
         nTziDB5tIqwigNymJY7NNZgWIVB3wXVqSYefBs7zgulMwpkAsLexoE8g4t4SJ2LAgFhG
         HL1C1YhyN623fwWEZSHgYZa406DsRyJ5XQ7fEXzr029CfXC9sPny3Zddhj1PfcwmHiW0
         yn+Y5O0FO6YFMnNp3eUAHo2SHb8VEWywz8EM2pAhMkO0imbC2Lj+S0HpJ9E+VtQ8tBk/
         +r87ijhJ0PKM2Of0pr98ffzcfF+IEOvP/t236SAOpyrdR3LMfRSflywXnJG+Md5gBKe3
         dzPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWIFa/sHqs6i3YkL5WR4CIqz1dkR7nio0jA64Xu38nTQicWxLiV
	xMKAD0zbaCxp4LpUmkLbyf8NqsaXiMXCvgJ705SkazEcp9w97E88Sw/EJJoVBxgVJJfRe/no332
	GaIFKtduljhp36Cg/BnMC+9jN7sTunKTpuTDggqdjg+SNM9e26ICC29aNP8VMUVzI8Q==
X-Received: by 2002:a37:93c4:: with SMTP id v187mr1314851qkd.166.1552624805293;
        Thu, 14 Mar 2019 21:40:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxruppAg5aVhvrSJdyMJigv60IbvVXpiLWQeBaJbPCNXoJiMRGU80slUF9TknxQF2yedkH
X-Received: by 2002:a37:93c4:: with SMTP id v187mr1314804qkd.166.1552624803900;
        Thu, 14 Mar 2019 21:40:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552624803; cv=none;
        d=google.com; s=arc-20160816;
        b=MjOgVdUd41/smSKvMtT6O2PjsvUtx6djmU067MD5Yb0bB9WykFydSd8cGHniNqhql3
         XkSEBorEplczcBpa97JXJiSR1DpGNYX9rahfTFnQ/wMmyCNVqJJWjBxrLELXa66mJJkV
         FOnyGGnQRCQrn77MdD/WGRFUcGSAGWXEpCVOeMA/fRx5S64ug3xG2FTjl1gU2WHxW/GL
         d3V3BXWX6ZOoYmKZD4ORPacXD/LFn4v6PTVxIkhvBLiU1aWMgtgVpOSzwlt++31lkWZg
         f0qhj+30ZGDknMnF3xc7mOVK5QLSTU/BNha24TdVlpZqLGpngTIARCNRTVlpyoeruy7C
         YE6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9lZt/iHfY5CFZ43vX5rjBw+OVsy+LF4uzOxN62wlTx8=;
        b=UTYVEDY2UiZh6PnYsEXZAJqYo1yEEroc6KS0FAwRZpWkkU0TDP1UzC+6Xvw4U0SMTd
         lNAMWiRz+PAlb71zC3SR5BvacCnLiswwrxtUeZ2kSo7aeWO820VG8jx+LH/Kgjde1qp4
         mAYQi3RcWq56AKPxPDOUJNhedysNMfhJydh4RGbz0UkaynfRN8ZOkT6Fn9rycdY34res
         Wkh9aZhr7qACxZqLqwYD/UOojleGI/nSE7iE3RNSGYEcwyM+qfnISjHNe+puBIDQUJe3
         6d8FhH0kEnSoLKuestV71/RbN+sUeAUCEQcwTQ5cCvBQ2Dkvdb38Cz3aR42JmsjAg+oZ
         8Pqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v58si577033qth.287.2019.03.14.21.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 21:40:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B41F811DB98;
	Fri, 15 Mar 2019 04:40:02 +0000 (UTC)
Received: from [10.72.12.187] (ovpn-12-187.pek2.redhat.com [10.72.12.187])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5A9B65E7DC;
	Fri, 15 Mar 2019 04:39:54 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>,
 kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
References: <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
 <20190313160529.GB15134@infradead.org>
 <1552495028.3022.37.camel@HansenPartnership.com>
 <20190314064004-mutt-send-email-mst@kernel.org>
 <74015196-2e18-4fe0-50ac-0c9d497315c7@redhat.com>
 <20190314193333.GA24542@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <37ef63f2-b2f5-a9b0-564a-912970e46af1@redhat.com>
Date: Fri, 15 Mar 2019 12:39:47 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190314193333.GA24542@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Mar 2019 04:40:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/15 上午3:33, Andrea Arcangeli wrote:
> Hello Jason,
>
> On Thu, Mar 14, 2019 at 09:49:03PM +0800, Jason Wang wrote:
>> Yes since we don't want to slow down 32bit.
> If you've a lot of ram there's no justification to stick to a 32bit
> kernel, so I don't think there's need to maintain a separate model
> just for 32bit. I really wouldn't care about the performance of 32bit
> with >700MB of RAM if that would cause any maintenance burden. Let's
> focus on the best 64bit implementation that will work equally
> optimally on 32bit with <= 700M of RAM.


Yes, but probably there are still some reasons of keeping copy_user() 
friends as a fallback. When we have a large virtqueue, the ring may 
occupy more than one page. This means the VA might not be contiguous 
when using kmap(). Instead of doing tricks in the accessories, maybe 
it's or simpler better just fall back to copy_user() in this case. And 
we meet the similar issue when software device IOTLB is used for vhost. 
And in the following example for gup, we can simply do a fallback when 
we race with the invalidation.

Michael also tends to keep the copy_user(), he suggested to use 
copy_user() for VIVT archs then there's no need for a explicit 
flush_dcache_page(). And he also want a module parameter for falling 
back to copy_user() for e.g debugging purpose.


>
> Talking to Jerome about the set_page_dirty issue, he raised the point
> of what happens if two thread calls a mmu notifier invalidate
> simultaneously. The first mmu notifier could call set_page_dirty and
> then proceed in try_to_free_buffers or page_mkclean and then the
> concurrent mmu notifier that arrives second, then must not call
> set_page_dirty a second time.
>
> With KVM sptes mappings and vhost mappings you would call
> set_page_dirty (if you invoked gup with FOLL_WRITE) only when
> effectively tearing down any secondary mapping (you've got pointers in
> both cases for the mapping). So there's no way to risk a double
> set_page_dirty from concurrent mmu notifier invalidate because the
> invalidate takes a lock when it has to teardown the mapping and so
> set_page_dirty is only run in the first invalidate method and not in
> the second. In the spte case even better, as you wouldn't need to call
> it even at teardown time unless the spte is dirty (if shadow mask
> allows dirty sptes with EPT2 or NPT or shadow MMU).


I see, the sounds indeed better.


>
> If you instead had to invalidate a secondary MMU mapping that isn't
> tracked by the driver (again: not vhost nor KVM case), you could have
> used the dirty bit of the kernel pagetable to call set_page_dirty and
> disambiguate but that's really messy, and it would prevent the use of
> gigapages in the direct mapping too and it'd require vmap for 4k
> tracking.
>
> To make sure set_page_dirty is run a single time no matter if the
> invalidate known when a mapping is tear down, I suggested the below
> model:
>
>    access = FOLL_WRITE
>
> repeat:
>    page = gup_fast(access)
>    put_page(page) /* need a way to drop FOLL_GET from gup_fast instead! */
>
>    spin_lock(mmu_notifier_lock);
>    if (race with invalidate) {
>      spin_unlock..
>      goto repeat;
>    }
>    if (access == FOLL_WRITE)
>      set_page_dirty(page)
>    establish writable mapping in secondary MMU on page
>    spin_unlock
>
> (replace spin_lock with mutex_lock for vhost of course if you stick to
> a mutex and _start/_end instead of non-sleepable ->invalidate_range)


Yes, I probably stick to the vq mutex since the invalidation needs to be 
synchronized with the whole packet processing routine.


> "race with invalidate" is the usual "mmu_notifier_retry" in kvm_host.h
> to be implemented for vhost.
>
> We could add a FOLL_DIRTY flag to add to FOLL_TOUCH to move the
> set_page_dirty inside GUP forced (currently it's not forced if the
> linux pte is already dirty). And we could remove FOLL_GET.
>
> Then if you have the ability to disambiguate which is the first
> invalidate that tears down a mapping to any given page (vhost can do
> that trivially, it's just a pointer to a page struct to kmap), in the
> mmu notifier invalidate just before dropping the spinlock you would
> do this check:
>
> def vhost_invalidate_range_start():
>     [..]
>     spin_lock(mmu_notifier_lock);
>     [..]
>     if (vhost->page_pointer) {
>        if (access == FOLL_WRITE)
> 	VM_WARN_ON(!PageDirty(vhost->page_pointer));
>        vhost->page_pointer = NULL;
>        /* no put_page, already done at gup time */
>     }
>     spin_unlock(..
>
> Generally speaking set_page_dirty is safer done after the last
> modification to the data of the page. However the way stable page
> works, as long as the mmu notifier invalidate didn't run, the PG_dirty
> cannot go away.


Ok.


>
> So this model solves the issue with guaranteeing a single
> set_page_dirty is run before page_mkclean or try_to_free_buffers can
> run, even for drivers that implement the invalidate as a generic "TLB
> flush" across the whole secondary MMU and that cannot disambiguate the
> first invalidate from a second invalidate if they're issued
> concurrently on the same address by two different CPUs.
>
> So for those drivers that can disambiguate trivially (like KVM and
> vhost) we'll just add a debug check in the invalidate to validate the
> common code for all mmu notifier users.
>
> This is the solution for RDMA hardware and everything that can support
> mmu notifiers too and they can take infinitely long secondary MMU
> mappins without interfering with stable pages at all (i.e. long term
> pins but without pinning) perfectly safe and transparent to the whole
> stable page code.
>
> I think O_DIRECT for stable pages shall be solved taking the page lock
> or writeback lock or a new rwsem in the inode that is taken for
> writing by page_mkclean and try_to_free_buffers and for reading by
> outstanding O_DIRECT in flight I/O, like I suggested probably ages ago
> but then we only made GUP take the page pin, which is fine for mmu
> notifier actually (except those didn't exist back then). To solve
> O_DIRECT we can leverage the 100% guarantee that the pin will be
> dropped ASAP and stop page_mkclean and stop or trylock in
> try_to_free_buffers in such case.
>
> mm_take_all_locks is major hurdle that prevents usage in O_DIRECT
> case, even if we "cache it" if you fork(); write; exit() in a loop
> it'll still cause heavy lock overhead. MMU notifier registration isn't
> intended to happen in fast and frequent paths like the write()
> syscall. Dropping mm_take_all_locks would bring other downsides: a
> regular quiescent point can happen in between _start/_end and _start
> must be always called first all the mmu notifier retry counters we
> rely on would break. One way would be to add srcu_read_lock _before_
> you can call mm_has_mm_has_notifiers(mm), then yes we could replace
> mm_take_all_locks with synchronize_srcu. It would save a lot of CPU
> and a ton of locked operations, but it'd potentially increase the
> latency of the registration so the first O_DIRECT write() in a process
> could still potentially stall (still better than mm_take_all_locks
> which would use a lot more CPU and hurt SMP scalability in threaded
> programs). The downside is all VM fast paths would get some overhead
> because of srcu_read_lock even when mmu notifier is not registered,
> which is what we carefully avoided by taking a larger hit in the
> registration with mm_take_all_locks. This is why I don't think mmu
> notifier is a good solution to solve O_DIRECT stable pages even in
> theory O_DIRECT could use the exact same model as vhost to solve
> stable pages.
>
> If we solve O_DIRECT with new per-page locking or a new rwsem inode
> lock leveraging the fact we're guaranteed the pin to go away ASAP,
> what's left is the case of PCI devices mapping userland memory for
> indefinite amount of time that cannot support MMU notifier because of
> hardware limitations.


Yes and this is part of the issue we met in vhost TX zerocopy code. 
What's more interesting is that a skb could be held of a software layer 
e.g qdisc as well. MMU notifier could be used for dealing with such 
software holding e.g copy packets into new pages. But this may requires 
more thoughts since this may race with networking stack.


>
> Mentioning virtualization as a case taking long term PIN is incorrect,
> that didn't happen since the introduction of MMU notifier.
>
> vfio for device assignment to KVM takes the long term pins, but that's
> because the iommus may not support the mmu notifier, mmu notifier
> could solve the vfio case too.


This might require the support of page faults from IOMMU hardware.


>
> PCI devices that pretend to keep a constant mapping on userland
> virtual memory and that cannot support MMU notifier because they lack
> a secondary MMU, cripple the Linux VM and there's no solution to
> that. Even if we solve the stable pages problem, they will still
> practically disable all advanced VM features.
>
> I think it would be ok to solve the stable pages in 3 different ways:
>
> 1) mmu notifier as above when mmu_notifier_register doesn't need to
>     run often and the hardware can support it
>
> 2) O_DIRECT with new locking stopping page_mkclean/try_to_free_buffers
>     until I/O completion, leveraging the fact the pin&lock are
>     guaranteed to be dropped&released ASAP
>
> 3) something else for pci devices that cannot support MMU notifier
>     because of hardware limitations, bounce buffers would be fine as
>     well
>
> I'm not even sure if in 3) it is worth worrying about being able to
> routinely flush to disk the dirty data, but then bounce buffers could
> solve that. Altering the page mapped in the pte sounds like a complex
> solution when you could copy the physical page just before issuing the
> I/O in the writeback code. To find if a GUP pin exists it's enough to
> check what KSM does:
>
> 		/*
> 		 * Check that no O_DIRECT or similar I/O is in progress on the
> 		 * page
> 		 */
> 		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
>
> That can give false positives (even through random pins coming from
> speculative cache lookups), but not false negatives.
>
> Thanks,
> Andrea


Thanks for the patient and detailed explanation with lots of 
backgrounds. It help to understand the whole picture a lot.


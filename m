Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B91BC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 14:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4992920868
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 14:58:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4992920868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7F0D8E0003; Fri,  8 Mar 2019 09:58:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2DBD8E0002; Fri,  8 Mar 2019 09:58:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C0C8E0003; Fri,  8 Mar 2019 09:58:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87E588E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 09:58:13 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b40so18862967qte.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 06:58:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jT6n4xTZcI6Lxg9SBN9RISvHkmJXNJVc0pv33PSswTg=;
        b=ABw39wTsWkBiWBY5ZoQRrbksLuD7nbjl2868p3rmUoIzxO9bNSr9fZRmId0U54PHQP
         56NVT2xkDynCtqjOuS5UmkFV6EDWVJ5Jds8lxMaRIb4vQ7l1VVnjRtLiZ0Qx8JAk3Y4B
         4fBOdpZU/plZRq2Or0KQ7Jlnc3I8N2NTQZys4YJNCbInzZcBtvY1Bea+EQNK3Ceh3i9p
         8axTAiLAhZNtVcstkxnY+uxmgJC9i8F9or3WPbkkWE7GjMt4Ur2olxOehyflFhFy20le
         oxelAQD+ZkKLR5pPkD590gMmfMXni9Ec3T3BJLcsz3m+PnXhloVqv9yMn4L6lEVZCNw6
         SM6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWuB9ik9OfPqOtGKDRYm+8j6iCqNsEbVTDsrF4/po8VYQbek0qQ
	ADAl4mcTLQ89e0rXurEXmh29AV7rgdMt3MHFhYIHCkthxtIwpCr+5CrNkmqf9N/pEi4z5WuwtKl
	rlzUgNE7bAEZ2j1CzkvOEORHlh6RjcUJPbWqkfB1odSQ+iT1fkNLVK4lDHKbte1T1Mg==
X-Received: by 2002:ac8:3276:: with SMTP id y51mr14974275qta.43.1552057093248;
        Fri, 08 Mar 2019 06:58:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqx9lY6lcjSayBHCDvNjB0OE4ET/mLEMDxRrt5UhkI50r3xApYjgmThTxq+LpouHFSebgxhn
X-Received: by 2002:ac8:3276:: with SMTP id y51mr14974210qta.43.1552057092130;
        Fri, 08 Mar 2019 06:58:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552057092; cv=none;
        d=google.com; s=arc-20160816;
        b=K6JMr/UDetenu3YNd0SQUFhCxULqYmxDBqs5DFKBbW//LwF51soh9trmDIaxrbYDhz
         Foz3yKbvhu/RamWJiAu/CP8V8z4SC/pQ7KHjSfEAg0/q/iT2WPXg8Cei8sLzZFEhnYGd
         OOb2xScbMTgnKpxYF0RpXs4/wDrPEjF1X384SodL1uCHlRfd95Vs+xwC0W8ROLzuMKkk
         eg0MpP1ezKSp3LgLJMwkCGqsb/PYY8LdjmgqYAbmQJ2NMbqkzpVhPY7p5Y6u9p3Qf/IU
         9PIvP374Wq8Ogxvbqb406qUvebJZNblZAX71wSyIJbvU8GXVqmAyVNlA+bVVuAD/DW/w
         jP6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jT6n4xTZcI6Lxg9SBN9RISvHkmJXNJVc0pv33PSswTg=;
        b=ZVSngg9idnuOWHaOv+RYWFdPAhjUYekFsG137du3tssmbQ0EymkukOpffe+YmiOvIh
         Xd5hNe5SnWYuUBL+UlIp1juXgFAzZjh2/OcP1Qd2lpQgRpgyVag/z/JNv7lsFOPfD71I
         zx4JzGL3pVBVrFL3pZ1wAriosx1FvFmcTmoJrEuFK0b8RV7cJKsIspTpZfawvJeyBt4N
         TBGxfVNNI81glAIiY4BaJX5Cigayl7QstEPQT560jgy8wpjKAcW+j6eFa2Tr6ybTdaQ5
         2IzTiQsPUK12sQtKteyl6hudEIfpJU+B1zxD3eVkBIet02/Bnn3c89cZBeywh8GL+yFB
         b5bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f35si1661866qte.129.2019.03.08.06.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 06:58:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 26733307CDC7;
	Fri,  8 Mar 2019 14:58:11 +0000 (UTC)
Received: from redhat.com (ovpn-124-248.rdu2.redhat.com [10.10.124.248])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F1D65D9CD;
	Fri,  8 Mar 2019 14:58:04 +0000 (UTC)
Date: Fri, 8 Mar 2019 09:58:01 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308145800.GA3661@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 08 Mar 2019 14:58:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
> 
> On 2019/3/8 上午3:16, Andrea Arcangeli wrote:
> > On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
> > > On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
> > > > On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> > > > > +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> > > > > +	.invalidate_range = vhost_invalidate_range,
> > > > > +};
> > > > > +
> > > > >   void vhost_dev_init(struct vhost_dev *dev,
> > > > >   		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
> > > > >   {
> > > > I also wonder here: when page is write protected then
> > > > it does not look like .invalidate_range is invoked.
> > > > 
> > > > E.g. mm/ksm.c calls
> > > > 
> > > > mmu_notifier_invalidate_range_start and
> > > > mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
> > > > 
> > > > Similarly, rmap in page_mkclean_one will not call
> > > > mmu_notifier_invalidate_range.
> > > > 
> > > > If I'm right vhost won't get notified when page is write-protected since you
> > > > didn't install start/end notifiers. Note that end notifier can be called
> > > > with page locked, so it's not as straight-forward as just adding a call.
> > > > Writing into a write-protected page isn't a good idea.
> > > > 
> > > > Note that documentation says:
> > > > 	it is fine to delay the mmu_notifier_invalidate_range
> > > > 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
> > > > implying it's called just later.
> > > OK I missed the fact that _end actually calls
> > > mmu_notifier_invalidate_range internally. So that part is fine but the
> > > fact that you are trying to take page lock under VQ mutex and take same
> > > mutex within notifier probably means it's broken for ksm and rmap at
> > > least since these call invalidate with lock taken.
> > Yes this lock inversion needs more thoughts.
> > 
> > > And generally, Andrea told me offline one can not take mutex under
> > > the notifier callback. I CC'd Andrea for why.
> > Yes, the problem then is the ->invalidate_page is called then under PT
> > lock so it cannot take mutex, you also cannot take the page_lock, it
> > can at most take a spinlock or trylock_page.
> > 
> > So it must switch back to the _start/_end methods unless you rewrite
> > the locking.
> > 
> > The difference with _start/_end, is that ->invalidate_range avoids the
> > _start callback basically, but to avoid the _start callback safely, it
> > has to be called in between the ptep_clear_flush and the set_pte_at
> > whenever the pfn changes like during a COW. So it cannot be coalesced
> > in a single TLB flush that invalidates all sptes in a range like we
> > prefer for performance reasons for example in KVM. It also cannot
> > sleep.
> > 
> > In short ->invalidate_range must be really fast (it shouldn't require
> > to send IPI to all other CPUs like KVM may require during an
> > invalidate_range_start) and it must not sleep, in order to prefer it
> > to _start/_end.
> > 
> > I.e. the invalidate of the secondary MMU that walks the linux
> > pagetables in hardware (in vhost case with GUP in software) has to
> > happen while the linux pagetable is zero, otherwise a concurrent
> > hardware pagetable lookup could re-instantiate a mapping to the old
> > page in between the set_pte_at and the invalidate_range_end (which
> > internally calls ->invalidate_range). Jerome documented it nicely in
> > Documentation/vm/mmu_notifier.rst .
> 
> 
> Right, I've actually gone through this several times but some details were
> missed by me obviously.
> 
> 
> > 
> > Now you don't really walk the pagetable in hardware in vhost, but if
> > you use gup_fast after usemm() it's similar.
> > 
> > For vhost the invalidate would be really fast, there are no IPI to
> > deliver at all, the problem is just the mutex.
> 
> 
> Yes. A possible solution is to introduce a valid flag for VA. Vhost may only
> try to access kernel VA when it was valid. Invalidate_range_start() will
> clear this under the protection of the vq mutex when it can block. Then
> invalidate_range_end() then can clear this flag. An issue is blockable is 
> always false for range_end().
> 

Note that there can be multiple asynchronous concurrent invalidate_range
callbacks. So a flag does not work but a counter of number of active
invalidation would. See how KSM is doing it for instance in kvm_main.c

The pattern for this kind of thing is:
    my_invalidate_range_start(start,end) {
        ...
        if (mystruct_overlap(mystruct, start, end)) {
            mystruct_lock();
            mystruct->invalidate_count++;
            ...
            mystruct_unlock();
        }
    }

    my_invalidate_range_end(start,end) {
        ...
        if (mystruct_overlap(mystruct, start, end)) {
            mystruct_lock();
            mystruct->invalidate_count--;
            ...
            mystruct_unlock();
        }
    }

    my_access_va(mystruct) {
    again:
        wait_on(!mystruct->invalidate_count)
        mystruct_lock();
        if (mystruct->invalidate_count) {
            mystruct_unlock();
            goto again;
        }
        GUP();
        ...
        mystruct_unlock();
    }

Cheers,
Jérôme


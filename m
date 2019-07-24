Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BFBBC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:26:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E05EA2190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:26:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E05EA2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64D626B0010; Wed, 24 Jul 2019 14:26:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FEA58E000B; Wed, 24 Jul 2019 14:26:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EE538E0007; Wed, 24 Jul 2019 14:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3105F6B0010
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:26:05 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x11so37801868qto.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:26:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=47jnRb/JRiGyeu7VRGBMaSdfmagEfI1RSsTJGA+iCS4=;
        b=l+TVm9zcIo60m4/aEX1VmOiPWxjbouSfZcJmDWWTnQcDL9Y8HfdANqknqto6Gq6oCe
         tFiBplILdltFR9tLFs960QXkMJyvQ5KxCZVnl69nJfeyyxZ0BdwHWKR8LwrjwyKGRvd1
         nXLL1jYe+OVDHDWQ5HzhEqMaCui3WYdcVU2PhkIWGymBzbWDew13hKfCwCwixo1l55Ja
         rOy5SNQXKcXcAV/BvHy1GNmZE9OvShTWnGuf6EYo9aJ2FYoJQp+9ZmJo2Zt18aPJSxdv
         JzJ6dWfOHT3d3AbyTFuoElqlF0M5O4j9jaHihQk6HN3qomn0RznReoRWZrbmUuA6aPH+
         1waQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVszbZC4hkLA/17SnlJnlEG+D2SKF4yCCsM6NaANdwo7pZq9HTv
	fccNAcNLrFP80xjmxMlpAc3H0BB+maZo9asT6fYvU2EIi0av1f3hr2l3yRksiZH/aJZoYFeImUs
	co8XSoB+1MXUQOVbM5sdEAj4e9oZyhqj4zMr471NHQLG767XacRGqy9FWstBLwWJD5A==
X-Received: by 2002:ac8:2971:: with SMTP id z46mr57414344qtz.322.1563992764965;
        Wed, 24 Jul 2019 11:26:04 -0700 (PDT)
X-Received: by 2002:ac8:2971:: with SMTP id z46mr57414305qtz.322.1563992764452;
        Wed, 24 Jul 2019 11:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563992764; cv=none;
        d=google.com; s=arc-20160816;
        b=v8p37JhKUeoIJR/zLO918pcSEz5AYvb8lcbHbjr8C6+rUkkeDv6SCln6lxI3MSomR6
         s4S7NmnWLIXcvHeF2VLmvKbsXnqxtI1SH1lN8AGg9q/+ta0/AC9gh1l4SOMdNoDd/TRR
         CjszHAFmI5PcPBuSu3vk50RSci+z/qrC/grI95NxsgeEF1Fp+gBC+RLRNFmlfTdH1Fbq
         PeKTDIgg17r26BGrHhgwiO/ii7k21D0dc2u27XxE1jRfDzuIUPQW2AEfuELNf5+8s51E
         CTM5yeO6xSfFc12hDLglCt+F9VLTgbKaoD411ZqmdB49TiM5xme+RWWwt+aBLqDyyeth
         EP0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=47jnRb/JRiGyeu7VRGBMaSdfmagEfI1RSsTJGA+iCS4=;
        b=TLkvXdcEKBFQay2FaY+wOwQR1mIxJAAQtDmdrKTsINJmqUhXJbZnq1IrpSM22Koa8y
         CetRNB6j+YxjP4rwmPF/aHRLW5arQrlIt9JER97YTJf2/UdAbCRYiaRwiTkqGXbseD3c
         axk0Bvxjhxcri0sU8zo3DKyWmThYr0EnRvEf/pzV9XC5VhyrObm14ucq+WeXT7O89STn
         gKkcgDT/WBc1vJ1+0DVJy47RSlezDJ3V4b8EMYl+jgKD67qUhi5D4ohn56WEvAku6afn
         cXJeEI4rg8FCKeethMFWfnbuD0dLdqjbdhqfGS2JoeT9VmhERyg95XfxU9iwGwCh0u87
         vQ+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d22sor62162571qtd.60.2019.07.24.11.26.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 11:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwzliSrA8epYeAr+o2o6Ky/lp4cNdeDzQCES2sBPCPVe5rhDvrrKAuGBvuFcp/RzeYu5u8tYg==
X-Received: by 2002:ac8:303c:: with SMTP id f57mr59008112qte.294.1563992764155;
        Wed, 24 Jul 2019 11:26:04 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id d26sm20464872qkl.97.2019.07.24.11.25.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 11:26:03 -0700 (PDT)
Date: Wed, 24 Jul 2019 14:25:54 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190724142533-mutt-send-email-mst@kernel.org>
References: <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
 <20190724040238-mutt-send-email-mst@kernel.org>
 <3dfa2269-60ba-7dd8-99af-5aef8552bd98@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3dfa2269-60ba-7dd8-99af-5aef8552bd98@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 06:08:05PM +0800, Jason Wang wrote:
> 
> On 2019/7/24 下午4:05, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午11:02, Michael S. Tsirkin wrote:
> > > > On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
> > > > > On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
> > > > > > > Yes, since there could be multiple co-current invalidation requests. We need
> > > > > > > count them to make sure we don't pin wrong pages.
> > > > > > > 
> > > > > > > 
> > > > > > > > I also wonder about ordering. kvm has this:
> > > > > > > >            /*
> > > > > > > >              * Used to check for invalidations in progress, of the pfn that is
> > > > > > > >              * returned by pfn_to_pfn_prot below.
> > > > > > > >              */
> > > > > > > >             mmu_seq = kvm->mmu_notifier_seq;
> > > > > > > >             /*
> > > > > > > >              * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
> > > > > > > >              * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
> > > > > > > >              * risk the page we get a reference to getting unmapped before we have a
> > > > > > > >              * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
> > > > > > > >              *
> > > > > > > >              * This smp_rmb() pairs with the effective smp_wmb() of the combination
> > > > > > > >              * of the pte_unmap_unlock() after the PTE is zapped, and the
> > > > > > > >              * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
> > > > > > > >              * mmu_notifier_seq is incremented.
> > > > > > > >              */
> > > > > > > >             smp_rmb();
> > > > > > > > 
> > > > > > > > does this apply to us? Can't we use a seqlock instead so we do
> > > > > > > > not need to worry?
> > > > > > > I'm not familiar with kvm MMU internals, but we do everything under of
> > > > > > > mmu_lock.
> > > > > > > 
> > > > > > > Thanks
> > > > > > I don't think this helps at all.
> > > > > > 
> > > > > > There's no lock between checking the invalidate counter and
> > > > > > get user pages fast within vhost_map_prefetch. So it's possible
> > > > > > that get user pages fast reads PTEs speculatively before
> > > > > > invalidate is read.
> > > > > > 
> > > > > > -- 
> > > > > In vhost_map_prefetch() we do:
> > > > > 
> > > > >           spin_lock(&vq->mmu_lock);
> > > > > 
> > > > >           ...
> > > > > 
> > > > >           err = -EFAULT;
> > > > >           if (vq->invalidate_count)
> > > > >                   goto err;
> > > > > 
> > > > >           ...
> > > > > 
> > > > >           npinned = __get_user_pages_fast(uaddr->uaddr, npages,
> > > > >                                           uaddr->write, pages);
> > > > > 
> > > > >           ...
> > > > > 
> > > > >           spin_unlock(&vq->mmu_lock);
> > > > > 
> > > > > Is this not sufficient?
> > > > > 
> > > > > Thanks
> > > > So what orders __get_user_pages_fast wrt invalidate_count read?
> > > 
> > > So in invalidate_end() callback we have:
> > > 
> > > spin_lock(&vq->mmu_lock);
> > > --vq->invalidate_count;
> > >          spin_unlock(&vq->mmu_lock);
> > > 
> > > 
> > > So even PTE is read speculatively before reading invalidate_count (only in
> > > the case of invalidate_count is zero). The spinlock has guaranteed that we
> > > won't read any stale PTEs.
> > > 
> > > Thanks
> > I'm sorry I just do not get the argument.
> > If you want to order two reads you need an smp_rmb
> > or stronger between them executed on the same CPU.
> > 
> > Executing any kind of barrier on another CPU
> > will have no ordering effect on the 1st one.
> > 
> > 
> > So if CPU1 runs the prefetch, and CPU2 runs invalidate
> > callback, read of invalidate counter on CPU1 can bypass
> > read of PTE on CPU1 unless there's a barrier
> > in between, and nothing CPU2 does can affect that outcome.
> > 
> > 
> > What did I miss?
> 
> 
> It doesn't harm if PTE is read before invalidate_count, this is because:
> 
> 1) This speculation is serialized with invalidate_range_end() because of the
> spinlock
> 
> 2) This speculation can only make effect when we read invalidate_count as
> zero.
> 
> 3) This means the speculation is done after the last invalidate_range_end()
> and because of the spinlock, when we enter the critical section of spinlock
> in prefetch, we can not see any stale PTE that was unmapped before.
> 
> Am I wrong?
> 
> Thanks

OK I think you are right. Sorry it took me a while to figure out.

-- 
MST


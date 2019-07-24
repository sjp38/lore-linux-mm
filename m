Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 706D7C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:05:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17AB3229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:05:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17AB3229ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C0976B0003; Wed, 24 Jul 2019 04:05:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 673446B0005; Wed, 24 Jul 2019 04:05:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5865A8E0002; Wed, 24 Jul 2019 04:05:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 375DD6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:05:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so40795236qtb.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:05:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=474FJ4CjTLJhnSN+huYP4Jd3bf8v5qgo4+UVMvlOmIY=;
        b=JUJ3T0v4cSYEsoY8L8l9dNpKTiH+90/VcYoIFPhkhUkbuT5EoMcJ4Q9ajqBV8/FDU9
         tSc73dKGVl5cnlZaLUeviNjtwecZNEUpEHl23a50A8JvaNQMiVySAFYGsGsh4HoaDAAC
         H5e74xxipcM7v+eqXbV0pyFA7T20yCLzukXk26zKLULs0frndy0/aPg+moKeRdVCugQp
         zMtY/xZlMfpy3IcJE8htAMFKwyWTW3NEfztUBjGBUOozxHRJWWSLD4OOBnIOKG9MuDAL
         Y/eGK4uVJTidhbxYvEMp1KduETY5Hq4iLFooScEZ6UJcZIR8CQFTby6x1TZVDqFWurHZ
         AeqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFVTO13zvJWWLD6d+jd87N8QBiyNIsJzWQSDYeZuzCQHe93Jwp
	fN3JVZBwUa3pDIqsGtWnswzYMVCniAdOJJPIHOzw50k856cF9g0bdkw0ZCz9AIi/RSvs80Txprj
	QUTD78kQ9KDUwVTWU5wWgRIg2uIlwbl8brJKQXzrdGH+GGq19+0BHKckz7yXFI3PlxA==
X-Received: by 2002:ae9:d610:: with SMTP id r16mr49842517qkk.16.1563955527943;
        Wed, 24 Jul 2019 01:05:27 -0700 (PDT)
X-Received: by 2002:ae9:d610:: with SMTP id r16mr49842478qkk.16.1563955527127;
        Wed, 24 Jul 2019 01:05:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563955527; cv=none;
        d=google.com; s=arc-20160816;
        b=PjA3ZtN4C5YWvej+Z8T/CKOtmvTQaQiy8VrtY7EMKp9mPRq3eO/kcnyM23N5E2jnQi
         Hn35yuXCw1BBvjoaOsB9jmCser56l23m0qPSg1GMkCYbbksPphhF49wUeVi3Ug59Iu4m
         S9wyqX87pBwi7z+IpnXAiptnWFDGelRqrZ4Ct6M2SW58MdTPmfjFthUAq5hyBZiLuVzQ
         giYRMAwPllOkljYVZ3zOHUs8OF9gWw32xCk9jVibBLSUVL/uEivGWyU5oHLfW95jFBAK
         x3cnAlqLPTnoed7evXermQCA5jpasW87IbOMr/NY7kSg+nZppuTo8jo7vmdGRlvhSWjL
         diWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=474FJ4CjTLJhnSN+huYP4Jd3bf8v5qgo4+UVMvlOmIY=;
        b=gDA5uFig9yi/957vJuXGdglRI75pSIx3AfrSlFdEiFmXcw0tvjFjtOA18ngO0q/TbB
         GWAxTATQylhdFZCh9zNYY+LcQ7h3XAfZZdliNlwLXT5UTyg49jFCOssUsXLNM7aOgDY+
         HJk6xQHBjKRkc6m1hNFFR33ha8rN0PxR2gXYAAL6nE+IuRgbr9paTR7mWxMFSxWVoAVe
         +5N+YxOftOJTuEhgWPnmtqicIbr5hjbAywwW4QigB8ss7jZkTH7ZDlun9CfKh61+0nWj
         kXBN6SskcOLP+JUDDyle+kzUneGY6X2XoqVhO3BPgW0yYJGmkBWhuOIHcFk2LhEqoIcX
         DbrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor60861356qtq.34.2019.07.24.01.05.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 01:05:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw6ZQ1xEgGDaGfr+FokaUeYzIX8sH8l8tvdJOvhZHCA1+JFXeX8ZY5yCCc6YIRs25mpDti6IA==
X-Received: by 2002:ac8:1106:: with SMTP id c6mr4002540qtj.332.1563955526892;
        Wed, 24 Jul 2019 01:05:26 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id u11sm19337738qkk.76.2019.07.24.01.05.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 01:05:25 -0700 (PDT)
Date: Wed, 24 Jul 2019 04:05:17 -0400
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
Message-ID: <20190724040238-mutt-send-email-mst@kernel.org>
References: <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午11:02, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
> > > > > Yes, since there could be multiple co-current invalidation requests. We need
> > > > > count them to make sure we don't pin wrong pages.
> > > > > 
> > > > > 
> > > > > > I also wonder about ordering. kvm has this:
> > > > > >           /*
> > > > > >             * Used to check for invalidations in progress, of the pfn that is
> > > > > >             * returned by pfn_to_pfn_prot below.
> > > > > >             */
> > > > > >            mmu_seq = kvm->mmu_notifier_seq;
> > > > > >            /*
> > > > > >             * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
> > > > > >             * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
> > > > > >             * risk the page we get a reference to getting unmapped before we have a
> > > > > >             * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
> > > > > >             *
> > > > > >             * This smp_rmb() pairs with the effective smp_wmb() of the combination
> > > > > >             * of the pte_unmap_unlock() after the PTE is zapped, and the
> > > > > >             * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
> > > > > >             * mmu_notifier_seq is incremented.
> > > > > >             */
> > > > > >            smp_rmb();
> > > > > > 
> > > > > > does this apply to us? Can't we use a seqlock instead so we do
> > > > > > not need to worry?
> > > > > I'm not familiar with kvm MMU internals, but we do everything under of
> > > > > mmu_lock.
> > > > > 
> > > > > Thanks
> > > > I don't think this helps at all.
> > > > 
> > > > There's no lock between checking the invalidate counter and
> > > > get user pages fast within vhost_map_prefetch. So it's possible
> > > > that get user pages fast reads PTEs speculatively before
> > > > invalidate is read.
> > > > 
> > > > -- 
> > > 
> > > In vhost_map_prefetch() we do:
> > > 
> > >          spin_lock(&vq->mmu_lock);
> > > 
> > >          ...
> > > 
> > >          err = -EFAULT;
> > >          if (vq->invalidate_count)
> > >                  goto err;
> > > 
> > >          ...
> > > 
> > >          npinned = __get_user_pages_fast(uaddr->uaddr, npages,
> > >                                          uaddr->write, pages);
> > > 
> > >          ...
> > > 
> > >          spin_unlock(&vq->mmu_lock);
> > > 
> > > Is this not sufficient?
> > > 
> > > Thanks
> > So what orders __get_user_pages_fast wrt invalidate_count read?
> 
> 
> So in invalidate_end() callback we have:
> 
> spin_lock(&vq->mmu_lock);
> --vq->invalidate_count;
>         spin_unlock(&vq->mmu_lock);
> 
> 
> So even PTE is read speculatively before reading invalidate_count (only in
> the case of invalidate_count is zero). The spinlock has guaranteed that we
> won't read any stale PTEs.
> 
> Thanks

I'm sorry I just do not get the argument.
If you want to order two reads you need an smp_rmb
or stronger between them executed on the same CPU.

Executing any kind of barrier on another CPU
will have no ordering effect on the 1st one.


So if CPU1 runs the prefetch, and CPU2 runs invalidate
callback, read of invalidate counter on CPU1 can bypass
read of PTE on CPU1 unless there's a barrier
in between, and nothing CPU2 does can affect that outcome.


What did I miss?

> 
> > 


Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D033C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F6C020644
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:22:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DjBOxER0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F6C020644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D978D6B000A; Wed, 22 May 2019 15:22:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D497B6B000C; Wed, 22 May 2019 15:22:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C37996B000D; Wed, 22 May 2019 15:22:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A36896B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:22:22 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n5so3223851qkf.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:22:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Wp5Bk2EWMnEeaZmBlDupB+bkUiiMoEJBLermtXKU6bE=;
        b=V6r9Vbtta0tN/AviUhNAwkDsdwBgNqun9qbklTSku4jZntEKNz4Lv856dyj0O7TwdE
         zxHNnGBb0T3C606zIhqPD4bJ+En78ZNDhbk7TweTUAOt4nwbCbMlrvuo7fOc63o23GPM
         h9SvYDi/cVmMILMBpTr8CX8Clh5etWd69JUvA4nlJt+j6MYZMcP/yBXqS/ByEANcWuRJ
         QyhN8Amc2Nu3cGzcvLoXQHAveYWWfZE19aa1GzvMLvnCmYB2G++WVngc66vgE87xehZU
         huzGeO/NoUwnQLgSfFnaPCQnsFir1ePQz7JkYxRzIMRi2Pmfd6eRYKp4jZS/qIn1yMyh
         /8fA==
X-Gm-Message-State: APjAAAWFcSMrhw+xDxkQoMqkU8XmbvX0nzc6pG0WBIxB+3x9oIc5ND/U
	9M8weaORPC+buyG1U271lArgr9HNDj5ZsipwYcZCYxBpXb0P2mlfVWSCiWDtU1IinDSsCn2cPu4
	xxUySYt1Cqy60PkAHmhf5tkVZxZtbQUn3kgNoSBveBgvD4VSQy0xO6684NdEUbUWYkg==
X-Received: by 2002:ac8:188c:: with SMTP id s12mr77662784qtj.9.1558552942329;
        Wed, 22 May 2019 12:22:22 -0700 (PDT)
X-Received: by 2002:ac8:188c:: with SMTP id s12mr77662716qtj.9.1558552941441;
        Wed, 22 May 2019 12:22:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558552941; cv=none;
        d=google.com; s=arc-20160816;
        b=0BKRWr9k63AbP7dz3hjGZ1cBtfq/wR2URZivNhrdfQ3uLH6WbZ2wGgaCMZxuIHIuNW
         oVvXZSFl+fNaOMrwWoD3sAiFeJTza+9Kij0k+5krweUWxWRQBerRh90+uZXUoxuMWMuF
         HlnvIpIcl3rLXBNj+nc/Hq5sl1mS75wtsNlWHAYhmdnZkO3XfZMfl3w5yh7TmZlwax4L
         wjQ4YoDp/HBsOmkZ1PHSi08jtyNKaaDIzGBpUdDB5pm4Wj0Rh0HVkuv2CtH7pjKe2dKv
         MrTdPJ+xt6dK3KYq1r9mAMfw3F9ZYFRYs4dQmx7ft+rH///EtlaSwOPjYtEJDRk1q43I
         27GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Wp5Bk2EWMnEeaZmBlDupB+bkUiiMoEJBLermtXKU6bE=;
        b=NQeMuM2LiEvYwAh99ka1Ofkdv6c2PWmDeTAMlfflXAKSp9ARAPps8RdRHtUBPrILAC
         5Yw1Yb6xoBJCQrysimyzZ3J8VL5GDTtM1m4P9b49CqmFIO37DQkltcnlQZJ7s5aQfKCJ
         mB/nwsULaa9H3SyGvYFTcm0HP3+Qku1ZAP1hFtE4cpGY6K9kqEQmxb7uzvQskiUxz2tm
         lglLuFH3ZbkCBMEv8aq+9O6PlggRpi+o+B4xcu3htSjEJCCycbp8HVhQyJZjEkBLzyLw
         63WJo+vhD0UBmxsm2wF93vKfGim1BJmpAycuYcqfySnzt+uOR2hn/61RJCrM4SqqDUNE
         beKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DjBOxER0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s30sor7361069qvs.35.2019.05.22.12.22.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 12:22:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DjBOxER0;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Wp5Bk2EWMnEeaZmBlDupB+bkUiiMoEJBLermtXKU6bE=;
        b=DjBOxER0Fvao/ulypH3vVJ/oVucLXSjayJw9Nr2jjTeFsa5xgys7H5j6rxAc6a2H6O
         GINB3tTfFRVU5DHqiEk9ToIuXNIIsysLchZy8dtq0d61lp38rNggWokEJjZiMOO0IWcQ
         ZtpxojpucG21nS0M6/CyF6elRwRpwbV8x/D5HwHg0aURFUn2YZJBnT20WFHicjrUEIEi
         8SJ6/NI2P7fpMiNad/xQ2gRoGMa2heaz17S4UpGg3yWlSfxeVpn8ItEJ2Uq1INWKFB9X
         6EVWxVdLQlMNZ/iSWWVFL7cdp+xN8WFIAUNn/X+d6XeMokIIeD19FoDBQNj5MFOxLDKM
         pGUg==
X-Google-Smtp-Source: APXvYqzmD5P4HTxWxqgxqvxyUOxZzdUj2GNpERtvq7g9PrGtnyoDI6LEXT/0uPV4kfzJKGrM8nd/fQ==
X-Received: by 2002:a0c:98a3:: with SMTP id f32mr73188614qvd.207.1558552941002;
        Wed, 22 May 2019 12:22:21 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id p10sm742262qke.65.2019.05.22.12.22.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 12:22:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTWod-0005iN-Ir; Wed, 22 May 2019 16:22:19 -0300
Date: Wed, 22 May 2019 16:22:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522192219.GF6054@ziepe.ca>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522174852.GA23038@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:

> > > +long ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
> > > +			       struct hmm_range *range)
> > >  {
> > > +	struct device *device = umem_odp->umem.context->device->dma_device;
> > > +	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> > >  	struct ib_umem *umem = &umem_odp->umem;
> > > -	struct task_struct *owning_process  = NULL;
> > > -	struct mm_struct *owning_mm = umem_odp->umem.owning_mm;
> > > -	struct page       **local_page_list = NULL;
> > > -	u64 page_mask, off;
> > > -	int j, k, ret = 0, start_idx, npages = 0, page_shift;
> > > -	unsigned int flags = 0;
> > > -	phys_addr_t p = 0;
> > > -
> > > -	if (access_mask == 0)
> > > +	struct mm_struct *mm = per_mm->mm;
> > > +	unsigned long idx, npages;
> > > +	long ret;
> > > +
> > > +	if (mm == NULL)
> > > +		return -ENOENT;
> > > +
> > > +	/* Only drivers with invalidate support can use this function. */
> > > +	if (!umem->context->invalidate_range)
> > >  		return -EINVAL;
> > >  
> > > -	if (user_virt < ib_umem_start(umem) ||
> > > -	    user_virt + bcnt > ib_umem_end(umem))
> > > -		return -EFAULT;
> > > +	/* Sanity checks. */
> > > +	if (range->default_flags == 0)
> > > +		return -EINVAL;
> > >  
> > > -	local_page_list = (struct page **)__get_free_page(GFP_KERNEL);
> > > -	if (!local_page_list)
> > > -		return -ENOMEM;
> > > +	if (range->start < ib_umem_start(umem) ||
> > > +	    range->end > ib_umem_end(umem))
> > > +		return -EINVAL;
> > >  
> > > -	page_shift = umem->page_shift;
> > > -	page_mask = ~(BIT(page_shift) - 1);
> > > -	off = user_virt & (~page_mask);
> > > -	user_virt = user_virt & page_mask;
> > > -	bcnt += off; /* Charge for the first page offset as well. */
> > > +	idx = (range->start - ib_umem_start(umem)) >> umem->page_shift;
> > 
> > Is this math OK? What is supposed to happen if the range->start is not
> > page aligned to the internal page size?
> 
> range->start is align on 1 << page_shift boundary within pagefault_mr
> thus the above math is ok. We can add a BUG_ON() and comments if you
> want.

OK

> > > +	range->pfns = &umem_odp->pfns[idx];
> > > +	range->pfn_shift = ODP_FLAGS_BITS;
> > > +	range->values = odp_hmm_values;
> > > +	range->flags = odp_hmm_flags;
> > >  
> > >  	/*
> > > -	 * owning_process is allowed to be NULL, this means somehow the mm is
> > > -	 * existing beyond the lifetime of the originating process.. Presumably
> > > -	 * mmget_not_zero will fail in this case.
> > > +	 * If mm is dying just bail out early without trying to take mmap_sem.
> > > +	 * Note that this might race with mm destruction but that is fine the
> > > +	 * is properly refcounted so are all HMM structure.
> > >  	 */
> > > -	owning_process = get_pid_task(umem_odp->per_mm->tgid, PIDTYPE_PID);
> > > -	if (!owning_process || !mmget_not_zero(owning_mm)) {
> > 
> > But we are not in a HMM context here, and per_mm is not a HMM
> > structure. 
> > 
> > So why is mm suddenly guarenteed valid? It was a bug report that
> > triggered the race the mmget_not_zero is fixing, so I need a better
> > explanation why it is now safe. From what I see the hmm_range_fault
> > is doing stuff like find_vma without an active mmget??
> 
> So the mm struct can not go away as long as we hold a reference on
> the hmm struct and we hold a reference on it through both hmm_mirror
> and hmm_range struct. So struct mm can not go away and thus it is
> safe to try to take its mmap_sem.

This was always true here, though, so long as the umem_odp exists the
the mm has a grab on it. But a grab is not a get..

The point here was the old code needed an mmget() in order to do
get_user_pages_remote()

If hmm does not need an external mmget() then fine, we delete this
stuff and rely on hmm.

But I don't think that is true as we have:

          CPU 0                                           CPU1
                                                       mmput()
                       				        __mmput()
							 exit_mmap()
down_read(&mm->mmap_sem);
hmm_range_dma_map(range, device,..
  ret = hmm_range_fault(range, block);
     if (hmm->mm == NULL || hmm->dead)
							   mmu_notifier_release()
							     hmm->dead = true
     vma = find_vma(hmm->mm, start);
        .. rb traversal ..                                 while (vma) remove_vma()

*goes boom*

I think this is violating the basic constraint of the mm by acting on
a mm's VMA's without holding a mmget() to prevent concurrent
destruction.

In other words, mmput() destruction does not respect the mmap_sem - so
holding the mmap sem alone is not enough locking.

The unlucked hmm->dead simply can't save this. Frankly every time I
look a struct with 'dead' in it, I find races like this.

Thus we should put the mmget_notzero back in.

I saw some other funky looking stuff in hmm as well..

> Hence it is safe to take mmap_sem and it is safe to call in hmm, if
> mm have been kill it will return EFAULT and this will propagate to
> RDMA.
 
> As per_mm i removed the per_mm->mm = NULL from release so that it is
> always safe to use that field even in face of racing mm "killing".

Yes, that certainly wasn't good.

> > > -	 * An array of the pages included in the on-demand paging umem.
> > > -	 * Indices of pages that are currently not mapped into the device will
> > > -	 * contain NULL.
> > > +	 * An array of the pages included in the on-demand paging umem. Indices
> > > +	 * of pages that are currently not mapped into the device will contain
> > > +	 * 0.
> > >  	 */
> > > -	struct page		**page_list;
> > > +	uint64_t *pfns;
> > 
> > Are these actually pfns, or are they mangled with some shift? (what is range->pfn_shift?)
> 
> They are not pfns they have flags (hence range->pfn_shift) at the
> bottoms i just do not have a better name for this.

I think you need to have a better name then

Jason


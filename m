Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6205AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:40:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167292064B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:40:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bpeSe/TO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167292064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F0D06B0003; Thu, 20 Jun 2019 04:40:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A3308E0002; Thu, 20 Jun 2019 04:40:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7906A8E0001; Thu, 20 Jun 2019 04:40:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4347F6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 04:40:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so1526345pfm.16
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:40:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=17FuFbjPRyXfho+sH140B0KsINkMD6CIqFuZH9j134k=;
        b=Wrsjt7tCTS0assct+zZbvqHZla9zzNsfRb4vkiEI5uufmn5N/4iARHPNtUndkUKXYs
         syPrI/olBsgbYyTMNKcH80XZ7/HBnDT+vvaM7De3WDOOBL7gQX4ANA87C1/YcbM7uExe
         JMdRyOJdPXq4BzanHCkyKzIq/XZgFyT/ioY7OraMmWoJjpV2eSG/QnfeZBaZyz/sjCLP
         WwYOIdUjm91wQmx71uAs9Q8Xhx37uEXqaI5GjAcTCMa71PdxSobAuGcubcQfrUj3Pt8+
         f6gR0SQlL5/dXyKetXlOgx5bDPShRfuKge2MGGOtNYDK879XDv44y6eauihq35FQodkq
         exTw==
X-Gm-Message-State: APjAAAW6hDZFr5kVZdO6BLKk8SU5LRFUdYObKGccdO6MQ8k3KAGWz86B
	STOMVzflsBK9MgYhtys8/j0PB0McnxMDlA6A/xQY2hvi9X9b7dVI3F0/AJDmIbEgUFIU2g6rTIk
	XX+5FoNvbF+MUsm6iIEcbYpFjipbnMTBCjO6MCO3plMxtP0oK4H4r6gGCHsFqSHE=
X-Received: by 2002:a17:902:6903:: with SMTP id j3mr48013549plk.247.1561020049890;
        Thu, 20 Jun 2019 01:40:49 -0700 (PDT)
X-Received: by 2002:a17:902:6903:: with SMTP id j3mr48013504plk.247.1561020049088;
        Thu, 20 Jun 2019 01:40:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561020049; cv=none;
        d=google.com; s=arc-20160816;
        b=dQGmJZvJCyaK056USCiqqIrOZtIioBnTHs+h8xJXeoA0AdMAqbKRxWfWaqyajTooLZ
         FCwLzrlLMOt9uhoky5ZwhfBmg5Z+Gg6R7bG+Fk3kxpTRp+Nt+pTfwQASAPkVHpKWQGjr
         UObdD3A0I19gokAE3PKkkwqL9t8LnVyJqixigRxh+vdUCR6hf/CR8XpEstkbdVOqngQp
         AdzrW+gNhfGl6dCLTw2vRFFSiRuvUT+PgKI+0F0DK2WyonhRngYY5Mp0aRXFfcQlEJd5
         +wXPIUDa2EXb6o7CxSbgC+9SfDigidSjLTEzG7xXOR6gw+eO+ukDN5xEs5bLFdhyZciy
         nbow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=17FuFbjPRyXfho+sH140B0KsINkMD6CIqFuZH9j134k=;
        b=knGRhP/HCIDPPQ8wkAGXiwxn6VqlCwesUDocWEzvw9JY2EUAxN8m2sZtzGHpt2Qpau
         fiTD1wVxdxrIPUK5e4ycBVV90VNTzCtje71Ax9nHRBUwtHA5CD1bY1uXRzzUOQG+wDIP
         e3d/TeyKCL6tp4zu05mBdZjPw3pkQZIHtWmhiqdLgH2vyFMQS7jOXsYVyLhAQTokHDqD
         hW/hczouAsFnqCGBIJJfFHG+j9tXuxp44VgPBnQBNJ7LivTOusToUOKRSeLiOxEZA7TH
         lrAaZ39qV0W1mJww1B9w0ucozVahYIc8YV4IimlzlNl5IMZUXm4irJWAuMtSpxSKzuX7
         neQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bpeSe/TO";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor24592091pls.61.2019.06.20.01.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 01:40:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bpeSe/TO";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=17FuFbjPRyXfho+sH140B0KsINkMD6CIqFuZH9j134k=;
        b=bpeSe/TO4VzZbxc/KZ2GE5LRHBCnLc4SONYYnNGkU9d54pqqLXNld/9R2UT8g9R2+B
         6o+WsxOzUvMmtRyHTWf+1mXxchfjlU2gKko+aJL7ivLuZ4pPOhDILf8o+JJQYTKQGYrG
         vaWITaJb+CmzdwpFHIpmnNbJZ1Dit8/zBA04M0XNIeQwbV/Yhf9vRxxY/p2x4qF13NcJ
         ghPEVWTvbpC/hEH7bfBk9wVkeg60J6XWu3xYttsIAUK7hTZ6imhU5l4TXPc+OmP1Ikj3
         tYeodl7OlTy2Hw//7WvY+N8RGltMdCFBb7jJ4TgJS3JnWigeNUzoFFiuu72I453PGbPO
         EjFw==
X-Google-Smtp-Source: APXvYqzsuQmdRBtyel5WmdHfE+nZt+hM5RlpYRct0NLIEycnp0qhp5IaVKy9GqrsUtL03dc/DAuhBA==
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr16187296plt.337.1561020048599;
        Thu, 20 Jun 2019 01:40:48 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j2sm28034806pfn.135.2019.06.20.01.40.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 01:40:47 -0700 (PDT)
Date: Thu, 20 Jun 2019 17:40:40 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190620084040.GD105727@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
 <20190620041620.GB105727@google.com>
 <20190620070444.GB12083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620070444.GB12083@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:04:44AM +0200, Michal Hocko wrote:
> On Thu 20-06-19 13:16:20, Minchan Kim wrote:
> > On Wed, Jun 19, 2019 at 03:24:50PM +0200, Michal Hocko wrote:
> > > On Mon 10-06-19 20:12:51, Minchan Kim wrote:
> > > [...]
> > > > +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > > > +				unsigned long end, struct mm_walk *walk)
> > > 
> > > Again the same question about a potential code reuse...
> > > [...]
> > > > +regular_page:
> > > > +	tlb_change_page_size(tlb, PAGE_SIZE);
> > > > +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > +	flush_tlb_batched_pending(mm);
> > > > +	arch_enter_lazy_mmu_mode();
> > > > +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> > > > +		ptent = *pte;
> > > > +		if (!pte_present(ptent))
> > > > +			continue;
> > > > +
> > > > +		page = vm_normal_page(vma, addr, ptent);
> > > > +		if (!page)
> > > > +			continue;
> > > > +
> > > > +		if (isolate_lru_page(page))
> > > > +			continue;
> > > > +
> > > > +		isolated++;
> > > > +		if (pte_young(ptent)) {
> > > > +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> > > > +							tlb->fullmm);
> > > > +			ptent = pte_mkold(ptent);
> > > > +			set_pte_at(mm, addr, pte, ptent);
> > > > +			tlb_remove_tlb_entry(tlb, pte, addr);
> > > > +		}
> > > > +		ClearPageReferenced(page);
> > > > +		test_and_clear_page_young(page);
> > > > +		list_add(&page->lru, &page_list);
> > > > +		if (isolated >= SWAP_CLUSTER_MAX) {
> > > 
> > > Why do we need SWAP_CLUSTER_MAX batching? Especially when we need ...
> > > [...]
> > 
> > It aims for preventing early OOM kill since we isolate too many LRU
> > pages concurrently.
> 
> This is a good point. For some reason I thought that we consider
> isolated pages in should_reclaim_retry but we do not anymore (since we
> move from zone to node LRUs I guess). Please stick a comment there.

Sure.

> 
> > > > +unsigned long reclaim_pages(struct list_head *page_list)
> > > > +{
> > > > +	int nid = -1;
> > > > +	unsigned long nr_reclaimed = 0;
> > > > +	LIST_HEAD(node_page_list);
> > > > +	struct reclaim_stat dummy_stat;
> > > > +	struct scan_control sc = {
> > > > +		.gfp_mask = GFP_KERNEL,
> > > > +		.priority = DEF_PRIORITY,
> > > > +		.may_writepage = 1,
> > > > +		.may_unmap = 1,
> > > > +		.may_swap = 1,
> > > > +	};
> > > > +
> > > > +	while (!list_empty(page_list)) {
> > > > +		struct page *page;
> > > > +
> > > > +		page = lru_to_page(page_list);
> > > > +		if (nid == -1) {
> > > > +			nid = page_to_nid(page);
> > > > +			INIT_LIST_HEAD(&node_page_list);
> > > > +		}
> > > > +
> > > > +		if (nid == page_to_nid(page)) {
> > > > +			list_move(&page->lru, &node_page_list);
> > > > +			continue;
> > > > +		}
> > > > +
> > > > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > > > +						NODE_DATA(nid),
> > > > +						&sc, 0,
> > > > +						&dummy_stat, false);
> > > 
> > > per-node batching in fact. Other than that nothing really jumped at me.
> > > Except for the shared page cache side channel timing aspect not being
> > > considered AFAICS. To be more specific. Pushing out a shared page cache
> > > is possible even now but this interface gives a much easier tool to
> > > evict shared state and perform all sorts of timing attacks. Unless I am
> > > missing something we should be doing something similar to mincore and
> > > ignore shared pages without a writeable access or at least document why
> > > we do not care.
> > 
> > I'm not sure IIUC side channel attach. As you mentioned, without this syscall,
> > 1. they already can do that simply by memory hogging
> 
> This is way much more harder for practical attacks because the reclaim
> logic is not fully under the attackers control. Having a direct tool to
> reclaim memory directly then just opens doors to measure the other
> consumers of that memory and all sorts of side channel.

Not sure it's much more harder. It's really easy on my experience.
Just creating new memory hogger and consume memory step by step until
you newly allocated pages will be reclaimed.
Anyway, we fixed mincore so attacker cannot see when the page fault-in
if he don't enough permission for the file. Right?
What's the concern of you even though we reclaim more aggressively?


> 
> > 2. If we need fix MADV_PAGEOUT, that means we need to fix MADV_DONTNEED, too?
> 
> nope because MADV_DONTNEED doesn't unmap from other processes.

Hmm, I don't understand. MADV_PAGEOUT doesn't unmap from other
processes, either. Could you elborate it a bit more what's your concern?


> -- 
> Michal Hocko
> SUSE Labs


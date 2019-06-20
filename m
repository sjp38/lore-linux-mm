Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9C9DC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CFF5208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qa3bydsI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CFF5208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96E3C6B0003; Thu, 20 Jun 2019 01:01:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91F128E0002; Thu, 20 Jun 2019 01:01:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 797698E0001; Thu, 20 Jun 2019 01:01:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7AB6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:01:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so39422pfn.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:01:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZnHKcO/AdXB5nY2IUk+trHT+q+fznBBu7HQwtNrjGAk=;
        b=kmM9g7Ct1TZnQMPEdO8RR/xJesNzzZaywu3ZOnLkAawenTJvXvL48CXkiq3VFeXsRO
         fpireZrTloip+cTrGwqbmbHZxU7AoEMF/soe5CTnv4NQgDjmms3sQZFmUvTjXS6PdORq
         fATKUyRrZ0i3el2QneK2SvJAsr59ApsjXS7M4isKe52yfCHcFd5FWcz141FSW6vFNl/0
         AUBZibgfH5GbbbobOPu4Uf/g91y1t5da0y3jqtgQh0poCi4fiB8eEQpj5gFV5cpqwCsq
         K1sNn7B2iVlm8t5Rt/jq+Sji5pzMlmV5UAERQ81THKSKSXhfKk88sAZ5P1fKxrlz0vYI
         Il/g==
X-Gm-Message-State: APjAAAX1uZtfw6FTnXtkutovzXU8ubOdzLk1xGkasiw9ny1FXxH4IcLy
	byzG16yNRMX5aAWxz/sdzX9f4vHiiXqlCfX/SDYFN7zS4mtK6VNA0Mkuzk3T/imk4XpMLLt9u06
	E3eNbgJ5b/A0PNcg1BL0u6gIpOrcACL6vXbNE9P5FwmSrirwd5QMdjSeEo10bt1I=
X-Received: by 2002:aa7:8e54:: with SMTP id d20mr38961137pfr.16.1561006901773;
        Wed, 19 Jun 2019 22:01:41 -0700 (PDT)
X-Received: by 2002:aa7:8e54:: with SMTP id d20mr38961064pfr.16.1561006900742;
        Wed, 19 Jun 2019 22:01:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561006900; cv=none;
        d=google.com; s=arc-20160816;
        b=rnIEdvdsvx/Bonlq4PvBZBwN8ieli/7REAQjJ90fM/HB3cfYN+vwMQTkV+fS578XbN
         6aasYEsiSH3wYfQRCb6cApxmMCyIDzD6xlix9aM5rFVU6ggAepcXahi+xR45qdNgoU53
         JK8BYGP3TMusic9n86tOThYqgQTu9gbis0L3oN1QRtvUEnYvaUhlBw7QoE0II3TutPac
         0c/MjDkrb3/5CrnmS/yOxo46O2geUY3PVaH3Vtq5z4K8IuTdJpHZVmpTQ/NX0xPowMDD
         dh90DLC5S6R4mrSpUHrms16vpls0eS68zN0yAU+1vV7upA/XDH98L+3AL4NhYhLGFvsL
         hvjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=ZnHKcO/AdXB5nY2IUk+trHT+q+fznBBu7HQwtNrjGAk=;
        b=fluOu2C/ey9VCQeU7e05zeqT7gz0Ujc4+O1eu5/gmPovKjld4AdCDX1sagK8GzTpr0
         8t3gbuL7WFZYpbTNU8p4rQjgB/4A2bY6SIFOOjn+75JTc/8uk/65qOS1+z+8+jQrG2Vz
         Ucd6RULVW5DcXEwsoQgYYSWQ64FUUK5GftH+B17ILnPmfGUSDgo3m8cO5hTztfVowZxp
         IZckgDaxMGvfkXFb79patlzKoEt8zWY/E9WRjAgR05XZiVULDw+qqcswkNizEdOBYVsh
         KGYKI0ZEgQY+RCUPEJtK02KX9mnxk1ZGMMweFhQhkLbebw3W5ahzKdzvKYGh74NV+jZk
         dYRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qa3bydsI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor17910121pgq.52.2019.06.19.22.01.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 22:01:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qa3bydsI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZnHKcO/AdXB5nY2IUk+trHT+q+fznBBu7HQwtNrjGAk=;
        b=Qa3bydsIHKJBhOMk7gYmp0o3qMDC3J5LhBP9lfxk1676C6RCjuIJ5yk6OTwQ6tk3U5
         oMR25pVuLTNI2CE3iStstuYkCoNFtMKo0RfCFvn1mRHdhyuZlRHr+fZ9qKMPB1HXrqFm
         rxae4Q9Gl+ojjqDc9sFeZQkOAqjopHSk8cg2D0l1ofFZdRiZj9+RY2v2VBg+dUg8RidI
         EMwcuUroZ7RX2BXI/CDHOIzDL7Y7DLfYKmgEW9Sd7wHIkXmbF1TV2gngnAsA8khnIOTa
         z5iMFTWNKEWSocl9UZE5KYPIlUv1g1jzGqkoks6uZPD3vyVWIJswB/SiMY5OLv9XKJan
         JjEA==
X-Google-Smtp-Source: APXvYqzsxnJB6epMwEqEkgB+WpWeMOmsTBRAbdAEBhcnSeNO6RQO5pNjIrNiARsQTnyP7EpksTPfUA==
X-Received: by 2002:a65:510c:: with SMTP id f12mr10859898pgq.92.1561006900098;
        Wed, 19 Jun 2019 22:01:40 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j8sm19364153pfi.148.2019.06.19.22.01.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 22:01:38 -0700 (PDT)
Date: Thu, 20 Jun 2019 14:01:32 +0900
From: Minchan Kim <minchan@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, vdavydov.dev@gmail.com
Subject: Re: [PATCH v1 1/4] mm: introduce MADV_COLD
Message-ID: <20190620050132.GC105727@google.com>
References: <20190603053655.127730-1-minchan@kernel.org>
 <20190603053655.127730-2-minchan@kernel.org>
 <20190604203841.GC228607@google.com>
 <20190610100904.GC55602@google.com>
 <20190612172104.GA125771@google.com>
 <20190613044824.GF55602@google.com>
 <20190619171340.GA83620@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619171340.GA83620@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:13:40PM -0400, Joel Fernandes wrote:
< snip >

Ccing Vladimir

> > > > > > +static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> > > > > > +				unsigned long end, struct mm_walk *walk)
> > > > > > +{
> > > > > > +	pte_t *orig_pte, *pte, ptent;
> > > > > > +	spinlock_t *ptl;
> > > > > > +	struct page *page;
> > > > > > +	struct vm_area_struct *vma = walk->vma;
> > > > > > +	unsigned long next;
> > > > > > +
> > > > > > +	next = pmd_addr_end(addr, end);
> > > > > > +	if (pmd_trans_huge(*pmd)) {
> > > > > > +		ptl = pmd_trans_huge_lock(pmd, vma);
> > > > > > +		if (!ptl)
> > > > > > +			return 0;
> > > > > > +
> > > > > > +		if (is_huge_zero_pmd(*pmd))
> > > > > > +			goto huge_unlock;
> > > > > > +
> > > > > > +		page = pmd_page(*pmd);
> > > > > > +		if (page_mapcount(page) > 1)
> > > > > > +			goto huge_unlock;
> > > > > > +
> > > > > > +		if (next - addr != HPAGE_PMD_SIZE) {
> > > > > > +			int err;
> > > > > > +
> > > > > > +			get_page(page);
> > > > > > +			spin_unlock(ptl);
> > > > > > +			lock_page(page);
> > > > > > +			err = split_huge_page(page);
> > > > > > +			unlock_page(page);
> > > > > > +			put_page(page);
> > > > > > +			if (!err)
> > > > > > +				goto regular_page;
> > > > > > +			return 0;
> > > > > > +		}
> > > > > > +
> > > > > > +		pmdp_test_and_clear_young(vma, addr, pmd);
> > > > > > +		deactivate_page(page);
> > > > > > +huge_unlock:
> > > > > > +		spin_unlock(ptl);
> > > > > > +		return 0;
> > > > > > +	}
> > > > > > +
> > > > > > +	if (pmd_trans_unstable(pmd))
> > > > > > +		return 0;
> > > > > > +
> > > > > > +regular_page:
> > > > > > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > > > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> > > > > > +		ptent = *pte;
> > > > > > +
> > > > > > +		if (pte_none(ptent))
> > > > > > +			continue;
> > > > > > +
> > > > > > +		if (!pte_present(ptent))
> > > > > > +			continue;
> > > > > > +
> > > > > > +		page = vm_normal_page(vma, addr, ptent);
> > > > > > +		if (!page)
> > > > > > +			continue;
> > > > > > +
> > > > > > +		if (page_mapcount(page) > 1)
> > > > > > +			continue;
> > > > > > +
> > > > > > +		ptep_test_and_clear_young(vma, addr, pte);
> > > > > 
> > > > > Wondering here how it interacts with idle page tracking. Here since young
> > > > > flag is cleared by the cold hint, page_referenced_one() or
> > > > > page_idle_clear_pte_refs_one() will not be able to clear the page-idle flag
> > > > > if it was previously set since it does not know any more that a page was
> > > > > actively referenced.
> > > > 
> > > > ptep_test_and_clear_young doesn't change PG_idle/young so idle page tracking
> > > > doesn't affect.
> > 
> > You said *young flag* in the comment, which made me confused. I thought you meant
> > PG_young flag but you mean PTE access bit.
> > 
> > > 
> > > Clearing of the young bit in the PTE does affect idle tracking.
> > > 
> > > Both page_referenced_one() and page_idle_clear_pte_refs_one() check this bit.
> > > 
> > > > > bit was previously set, just so that page-idle tracking works smoothly when
> > > > > this hint is concurrently applied?
> > > > 
> > > > deactivate_page will remove PG_young bit so that the page will be reclaimed.
> > > > Do I miss your point?
> > > 
> > > Say a process had accessed PTE bit not set, then idle tracking is run and PG_Idle
> > > is set. Now the page is accessed from userspace thus setting the accessed PTE
> > > bit.  Now a remote process passes this process_madvise cold hint (I know your
> > > current series does not support remote process, but I am saying for future
> > > when you post this). Because you cleared the PTE accessed bit through the
> > > hint, idle tracking no longer will know that the page is referenced and the
> > > user gets confused because accessed page appears to be idle.
> > 
> > Right.
> > 
> > > 
> > > I think to fix this, what you should do is clear the PG_Idle flag if the
> > > young/accessed PTE bits are set. If PG_Idle is already cleared, then you
> > > don't need to do anything.
> > 
> > I'm not sure. What does it make MADV_COLD special?
> > How about MADV_FREE|MADV_DONTNEED?
> > Why don't they clear PG_Idle if pte was young at tearing down pte? 
> 
> Good point, so it sounds like those (MADV_FREE|MADV_DONTNEED) also need to be fixed then?

Not sure. If you want it, maybe you need to fix every pte clearing and pte_mkold
part, which is more general to cover every sites like munmap, get_user_pages and
so on. Anyway, I don't think it's related to this patchset.

> 
> > The page could be shared by other processes so if we miss to clear out
> > PG_idle in there, page idle tracking could miss the access history forever.
> 
> I did not understand this. So say a page X is shared process P and Q and
> assume the PG_idle flag is set on the page.
> 
> P accesses memory and has the pte accessed bit set. P now gets the MADV_COLD
> hint and forgets to clear the idle flag while clearing the pte accessed bit.
> 
> Now the page appears to be idle, even though it was not. This has nothing to
> do with Q and whether the page is shared or not.

What I meant was MADV_FREE|MADV_DONTNEED.

> 
> > If it's not what you want, maybe we need to fix all places all at once.
> > However, I'm not sure. Rather than, I want to keep PG_idle in those hints
> > even though pte was accesssed because the process now gives strong hint
> > "The page is idle from now on". It's valid because he knows himself better than
> > others, even admin. IOW, he declare the page is not workingset any more.
> 
> Even if the PG_idle flag is not cleared - it is not a strong hint for working
> set size IMHO, because the page *was* accessed so the process definitely needed the
> page at some point even though now it says it is MADV_COLD. So that is part
> of working set. I don't think we should implicitly provide such hints and we
> should fix it.
> 
> Also I was saying in previous email, if process_madvise (future extension) is
> called from say activity manager, then the process and the user running the
> idle tracking feature has no idea that the page was accessed because the idle
> flag is still set. That is a bit weird and is loss of information.
> 
> It may not be a big deal in the long run if the page is accessed a lot, since
> the PTE accessed bit will be set again and idle-tracking feature may not miss
> it, but why leave it to chance if it is a simple fix?

Consistency with other madvise hints.

There are many places you could lose the information as I mentioned and I'm
really not conviced we need fixing because currently page-idle tracking
feature is biased to work with . If you believe we need to fix it,
it would be better to have a separate discussion, not here.

> 
> > What's the problem if page idle tracking feature miss it?
> 
> What's the problem if PG_idle flag is cleared here? It is just a software
> flag.

Again consistency. I don't think it's a MADV_PAGEOUT specific issue.
Since I pointed out other places idle tracking is missing(? not sure),
Let's discuss it separately if you feel we need fix.

Furthermore, once the page is reclaimed, that means the page could be
deallocated so you automatically don't see any PG_idle from the page.

> 
> > If other processs still have access bit of their pte for the page, page idle
> > tracking could find the page as non-idle so it's no problem, either.
> 
> Yes, but if the other process also does not access the page, then the access
> information is lost.
> 
> thanks!
> 
>  - Joel
> 


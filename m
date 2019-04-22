Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 213B5C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCC0F20675
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:29:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Boh3XzRN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCC0F20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BD016B0003; Mon, 22 Apr 2019 17:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693F06B0006; Mon, 22 Apr 2019 17:29:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583396B0007; Mon, 22 Apr 2019 17:29:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 331956B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 17:29:30 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id r14so6136569vkd.18
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:29:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j6ZNX8PzZTc2KzrAqgh1Ng4laLRheQ1IuJOBZqlb3Bs=;
        b=O03UBlaLSvFLQ79VOWOsCZ9uz3NGML8MSDM+5Rcp8gzlpnCe2v4B/ngOA62m3TgE8C
         lXpQQe/y+bcjR4TgP0Qh9K5d7NJoPItP60vqXwRg/I8xkyD1MSS3CG1UMgHrcsLbE9fE
         /Qt6VQmC6+GDc4I0YCiETLf4zpINRdNeeZ2vKqE+Snb2mG97rCBteO1ryvAwrM3Gu/Qv
         r2tGQ1gEqHcqKHm1SgkXRTwKDf4TcHPSg+/XZ5WjajisooiRq/M/CRY6EuVrBMVZxD0b
         AQUE5WqgnXDFUDDTKgqZJK8fSPDpJTmEZhOtIProST/pkTgywLkbLot57G+HN7jwhbWI
         1ZEQ==
X-Gm-Message-State: APjAAAVkVIwLAxpSAsetNbpKbhW1lvrq3EOxwwkVziL/FrhhhxTCE/SO
	0ajOP471QWLdfH6phuzWT6WidAlq4nTwcJZS4az/xWYiVSX4qGzi4uwGr5W3z/gASHrmDHnbDds
	hzq75oA49rsZD/uBNQ0Kh9gEjkffHkoXukyCA3lahRGe89V/9Yui00YTTukTvjmCI0A==
X-Received: by 2002:a05:6102:201:: with SMTP id z1mr11015806vsp.43.1555968569855;
        Mon, 22 Apr 2019 14:29:29 -0700 (PDT)
X-Received: by 2002:a05:6102:201:: with SMTP id z1mr11015772vsp.43.1555968569026;
        Mon, 22 Apr 2019 14:29:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555968569; cv=none;
        d=google.com; s=arc-20160816;
        b=HB2WwkLX+tsoosG4c8xjpVCEwrdaoIjuCipfYMlsYzGR5VSgi4kcXJ9WEP/0iE9IC9
         nisP7AatoSvgYckEwOSlduJff4s72ZTE2I7Pnarkpy8NVbJrQY/D0jwmV+LPbdpyJOSv
         dVhgBCAU4Xg7aZxzJlW9MzZrABbyBCNoJ+2cHvEJjjPaL+rTXXJ+PSQuIErveIcderxj
         bXRUkaTSAsVPcxe+RHddvrW5XuSER9Ouk7rQUgkfSffHOUX7CG9BFbBNk9gVeYuCvy/Y
         9E1u/UY7QQNzQfGm3H+/niY0uo6ZTQpteWETJzqvKhzK7+OkWxolt9fwM0MfE+N/Eh6N
         R5tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j6ZNX8PzZTc2KzrAqgh1Ng4laLRheQ1IuJOBZqlb3Bs=;
        b=DO0TIreP3usV9n96O1lfkT9tKbnXJzAH0M4jFa7Dxd+9A7qoW7TOGhUCxkrcXD6+Vi
         BoxMxuKpTIH/lYpUjcvh+ARSDeWu7mDoHeD5JY3HKNkLwp7Xs9IPtByCeySLRpoODJ3w
         pVO8qfO1nKCtGJAKXjmGgb2d36AU5HraUs0ZHm81iCqUa9pQQWJ78gyxLtrIA5aQtiJ5
         eYD3YMQmei4fcwLEIkvC5bkRL+PVM/F6aEYkNqYWfi9bvDC1LY2pTrEFxdfoB8Xl/Bi6
         wnEXELODhhZcOiCfp1ddxKH3d9j3xXoMVyy3+Z0/wUFma+ilfZUeeXwO40GlpHA9v5XS
         e5QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Boh3XzRN;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor4765973vkl.56.2019.04.22.14.29.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Apr 2019 14:29:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Boh3XzRN;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j6ZNX8PzZTc2KzrAqgh1Ng4laLRheQ1IuJOBZqlb3Bs=;
        b=Boh3XzRNxD117G85f/L05gtwAnDAfHoPs9C1FhzigFYfOnfP0eH2Ibrg1KsROyHkXG
         E5FokjelGfi7bsSOKsnu/qDQybbKcNTShOUMhOPHQUSZLq3sTgesj44PcT+sLLvcP0u1
         0zprQt1JN4vP4+kxx0XnT7UE+8fflPPsY81LEbfMtNSQFyD/dmCc6KkcEq7RHfflccuJ
         k7oxWsl6T6plZHXzE7oObRUH+TJBP6n7E8Xh9mkAtD3F0D5QHEPkcEPDVzor0meP454r
         ivW5OATTTiYvx8CEC+AWPGD54CmOlxJRr3T9iS5AqO1cuZY4F8dg8Bfqa3XGFY4IJ/lb
         1TkQ==
X-Google-Smtp-Source: APXvYqyayLq7fveYwsVJYv2RL6WtmqgCh4VRowXNECgcbX8d5XclmkCqh6hazJDdUL3SB6G8DBLVF2TroVADzI3hjsU=
X-Received: by 2002:a1f:a0d2:: with SMTP id j201mr11280429vke.37.1555968568316;
 Mon, 22 Apr 2019 14:29:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
From: Michel Lespinasse <walken@google.com>
Date: Mon, 22 Apr 2019 14:29:16 -0700
Message-ID: <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
Subject: Re: [PATCH v12 00/31] Speculative page faults
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, 
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, 
	Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, mpe@ellerman.id.au, 
	Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, 
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, 
	Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, 
	vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, 
	zhong jiang <zhongjiang@huawei.com>, Haiyan Song <haiyanx.song@intel.com>, 
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com, 
	Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, 
	Nick Piggin <npiggin@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, 
	Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Laurent,

Thanks a lot for copying me on this patchset. It took me a few days to
go through it - I had not been following the previous iterations of
this series so I had to catch up. I will be sending comments for
individual commits, but before tat I would like to discuss the series
as a whole.

I think these changes are a big step in the right direction. My main
reservation about them is that they are additive - adding some complexity
for speculative page faults - and I wonder if it'd be possible, over the
long term, to replace the existing complexity we have in mmap_sem retry
mechanisms instead of adding to it. This is not something that should
block your progress, but I think it would be good, as we introduce spf,
to evaluate whether we could eventually get all the way to removing the
mmap_sem retry mechanism, or if we will actually have to keep both.


The proposed spf mechanism only handles anon vmas. Is there a
fundamental reason why it couldn't handle mapped files too ?
My understanding is that the mechanism of verifying the vma after
taking back the ptl at the end of the fault would work there too ?
The file has to stay referenced during the fault, but holding the vma's
refcount could be made to cover that ? the vm_file refcount would have
to be released in __free_vma() instead of remove_vma; I'm not quite sure
if that has more implications than I realize ?

The proposed spf mechanism only works at the pte level after the page
tables have already been created. The non-spf page fault path takes the
mm->page_table_lock to protect against concurrent page table allocation
by multiple page faults; I think unmapping/freeing page tables could
be done under mm->page_table_lock too so that spf could implement
allocating new page tables by verifying the vma after taking the
mm->page_table_lock ?

The proposed spf mechanism depends on ARCH_HAS_PTE_SPECIAL.
I am not sure what is the issue there - is this due to the vma->vm_start
and vma->vm_pgoff reads in *__vm_normal_page() ?


My last potential concern is about performance. The numbers you have
look great, but I worry about potential regressions in PF performance
for threaded processes that don't currently encounter contention
(i.e. there may be just one thread actually doing all the work while
the others are blocked). I think one good proxy for measuring that
would be to measure a single threaded workload - kernbench would be
fine - without the special-case optimization in patch 22 where
handle_speculative_fault() immediately aborts in the single-threaded case.

Reviewed-by: Michel Lespinasse <walken@google.com>
This is for the series as a whole; I expect to do another review pass on
individual commits in the series when we have agreement on the toplevel
stuff (I noticed a few things like out-of-date commit messages but that's
really minor stuff).


I want to add a note about mmap_sem. In the past there has been
discussions about replacing it with an interval lock, but these never
went anywhere because, mostly, of the fact that such mechanisms were
too expensive to use in the page fault path. I think adding the spf
mechanism would invite us to revisit this issue - interval locks may
be a great way to avoid blocking between unrelated mmap_sem writers
(for example, do not delay stack creation for new threads while a
large mmap or munmap may be going on), and probably also to handle
mmap_sem readers that can't easily use the spf mechanism (for example,
gup callers which make use of the returned vmas). But again that is a
separate topic to explore which doesn't have to get resolved before
spf goes in.


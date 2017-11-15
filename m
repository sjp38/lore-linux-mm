Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07C1A6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:14:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z184so23136192pgd.0
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 00:14:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a82si11145038pfk.98.2017.11.15.00.14.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 00:14:56 -0800 (PST)
Date: Wed, 15 Nov 2017 09:14:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171115081452.bt7cpfombm4bzha4@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171113002833.GA18301@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171113002833.GA18301@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Mon 13-11-17 09:28:33, Minchan Kim wrote:
[...]
> void arch_tlb_gather_mmu(...)
> 
>         tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;

Sorry, I should have realized sooner but this will not work for the oom
reaper. It _can_ race with the final exit_mmap and run with mm_users == 0
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

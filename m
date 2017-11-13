Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A22BA280244
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 04:51:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y42so8784729wrd.23
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 01:51:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d14si3329710edj.430.2017.11.13.01.51.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 01:51:10 -0800 (PST)
Date: Mon, 13 Nov 2017 10:51:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171113095107.24hstywywxk7nx7e@dhcp22.suse.cz>
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
> Thanks for the patch, Michal.
> However, it would be nice to do it tranparently without asking
> new flags from users.
> 
> When I read tlb_gather_mmu's description, fullmm is supposed to
> be used only if there is no users and full address space.
> 
> That means we can do it API itself like this?
> 
> void arch_tlb_gather_mmu(...)
> 
>         tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;

I do not have a strong opinion here. The optimization is quite subtle so
calling it explicitly sounds like a less surprising behavior to me
longterm. Note that I haven't checked all fullmm users.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

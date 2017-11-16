Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2073D6B027E
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:45:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 207so20538374pgc.21
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:45:00 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o15si1386265pgf.485.2017.11.15.16.44.58
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 16:44:59 -0800 (PST)
Date: Thu, 16 Nov 2017 09:44:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171116004457.GA12222@bbox>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171113002833.GA18301@bbox>
 <20171115081452.bt7cpfombm4bzha4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115081452.bt7cpfombm4bzha4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Nov 15, 2017 at 09:14:52AM +0100, Michal Hocko wrote:
> On Mon 13-11-17 09:28:33, Minchan Kim wrote:
> [...]
> > void arch_tlb_gather_mmu(...)
> > 
> >         tlb->fullmm = !(start | (end + 1)) && atomic_read(&mm->mm_users) == 0;
> 
> Sorry, I should have realized sooner but this will not work for the oom
> reaper. It _can_ race with the final exit_mmap and run with mm_users == 0

If someone see mm_users is zero, it means there is no user to access
address space by stale TLB. Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

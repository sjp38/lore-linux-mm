Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85BBF6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 02:21:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 27so5486258pft.8
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 23:21:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c69si16847980pfl.193.2017.11.13.23.21.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 23:21:03 -0800 (PST)
Date: Tue, 14 Nov 2017 08:21:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171114072100.uwkbakxzdkroga7r@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171113002833.GA18301@bbox>
 <20171113095107.24hstywywxk7nx7e@dhcp22.suse.cz>
 <20171114014549.GA1995@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114014549.GA1995@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Tue 14-11-17 10:45:49, Minchan Kim wrote:
[...]
> Anyway, I think Wang Nan's patch is already broken.
> http://lkml.kernel.org/r/%3C20171107095453.179940-1-wangnan0@huawei.com%3E
> 
> Because unmap_page_range(ie, zap_pte_range) can flush TLB forcefully
> and free pages. However, the architecture code for TLB flush cannot
> flush at all by wrong fullmm so other threads can write freed-page.

I am not sure I understand what you mean. How is that any different from
any other explicit partial madvise call?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

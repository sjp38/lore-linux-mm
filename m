Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCBE76B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:05:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n187so4780854pfn.10
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:05:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si2903573pgv.757.2017.12.14.06.05.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 06:05:07 -0800 (PST)
Date: Thu, 14 Dec 2017 15:05:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_exit
Message-ID: <20171214140504.GP16951@dhcp22.suse.cz>
References: <20171205145853.26614-1-mhocko@kernel.org>
 <CA+55aFw3NKzVO3xivjV1MzFH_wC1-eVAvgkHjpp7T7__CF6+eg@mail.gmail.com>
 <20171205191410.f2rvaluftnd6dqer@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205191410.f2rvaluftnd6dqer@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Minchan Kim <minchan@kernel.org>, Andrea Argangeli <andrea@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 05-12-17 20:14:37, Michal Hocko wrote:
> On Tue 05-12-17 10:31:12, Linus Torvalds wrote:
> > On Tue, Dec 5, 2017 at 6:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > This all is nice but tlb_gather users are not aware of that and this can
> > > actually cause some real problems. E.g. the oom_reaper tries to reap the
> > > whole address space but it might race with threads accessing the memory [1].
> > > It is possible that soft-dirty handling might suffer from the same
> > > problem [2] as soon as it starts supporting the feature.
> > 
> > So we fixed the oom reaper to just do proper TLB invalidates in commit
> > 687cb0884a71 ("mm, oom_reaper: gather each vma to prevent leaking TLB
> > entry").
> > 
> > So now "fullmm" should be the expected "exit" case, and it all should
> > be unambiguous.
> > 
> > Do we really have any reason to apply this patch any more?
> 
> Well, the point was the clarity. The bad behavior came as a surprise for
> the oom reaper and as Minchan mentioned we would see a similar problem
> with soft-dirty bits as soon as they are supported on arm64 or
> potentially other architectures which might do special handling for exit
> case.

I am not going to push this patch if it is considered pointless but I
haven't heard back anything to the above argument.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 170546B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 13:31:15 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x32so16711215ita.1
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 10:31:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e89sor585044itd.2.2017.12.05.10.31.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 10:31:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171205145853.26614-1-mhocko@kernel.org>
References: <20171205145853.26614-1-mhocko@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Dec 2017 10:31:12 -0800
Message-ID: <CA+55aFw3NKzVO3xivjV1MzFH_wC1-eVAvgkHjpp7T7__CF6+eg@mail.gmail.com>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_exit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Minchan Kim <minchan@kernel.org>, Andrea Argangeli <andrea@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 5, 2017 at 6:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> This all is nice but tlb_gather users are not aware of that and this can
> actually cause some real problems. E.g. the oom_reaper tries to reap the
> whole address space but it might race with threads accessing the memory [1].
> It is possible that soft-dirty handling might suffer from the same
> problem [2] as soon as it starts supporting the feature.

So we fixed the oom reaper to just do proper TLB invalidates in commit
687cb0884a71 ("mm, oom_reaper: gather each vma to prevent leaking TLB
entry").

So now "fullmm" should be the expected "exit" case, and it all should
be unambiguous.

Do we really have any reason to apply this patch any more?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

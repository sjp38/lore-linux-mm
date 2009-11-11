Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6F54D6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 00:51:10 -0500 (EST)
Received: by pzk34 with SMTP id 34so555157pzk.11
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:51:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0911102202500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
	 <Pine.LNX.4.64.0911102202500.2816@sister.anvils>
Date: Wed, 11 Nov 2009 14:51:08 +0900
Message-ID: <28c262360911102151n349bd2a5x2749f1cb5653ed43@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm: sigbus instead of abusing oom
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 11, 2009 at 7:06 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> When do_nonlinear_fault() realizes that the page table must have been
> corrupted for it to have been called, it does print_bad_pte() and
> returns ... VM_FAULT_OOM, which is hard to understand.
>
> It made some sense when I did it for 2.6.15, when do_page_fault()
> just killed the current process; but nowadays it lets the OOM killer
> decide who to kill - so page table corruption in one process would
> be liable to kill another.
>
> Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee
> that the process will be killed, but is good enough for such a rare
> abnormality, accompanied as it is by the "BUG: Bad page map" message.
>
> And recent HWPOISON work has copied that code into do_swap_page(),
> when it finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
I already agreed this. :)
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

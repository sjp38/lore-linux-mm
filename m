Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 665666B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:46:40 -0500 (EST)
Received: by pxi5 with SMTP id 5so16762220pxi.12
        for <linux-mm@kvack.org>; Tue, 12 Jan 2010 06:46:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100112141330.B3A6.A69D9226@jp.fujitsu.com>
References: <20100112141330.B3A6.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Jan 2010 23:46:38 +0900
Message-ID: <28c262361001120646y6f3603b8q236d0a7c02250ffa@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, lockdep: annotate reclaim context to zone
	reclaim too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 2:16 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Commit cf40bd16fd (lockdep: annotate reclaim context) introduced reclaim
> context annotation. But it didn't annotate zone reclaim. This patch do it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Ingo Molnar <mingo@elte.hu>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I think your good explanation in previous thread is good for
changelog. so I readd in here.
If you mind this, feel free to discard.
I don't care about it. :)

---

<kosaki.motohiro@jp.fujitsu.com> wrote:
The point is zone-reclaim doesn't use
__alloc_pages_direct_reclaim.
current call graph is

__alloc_pages_nodemask
   get_page_from_freelist
       zone_reclaim()
   __alloc_pages_slowpath
       __alloc_pages_direct_reclaim
           try_to_free_pages

Actually, if zone_reclaim_mode=1, VM never call
__alloc_pages_direct_reclaim in usual VM pressure.
Thus I think zone-reclaim should be annotated explicitly too.
I know almost user don't use zone reclaim mode. but explicit
annotation doesn't have any demerit, I think.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

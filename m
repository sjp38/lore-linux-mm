Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 471AB6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 23:06:58 -0400 (EDT)
Date: Thu, 26 Apr 2012 20:08:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
Message-Id: <20120426200845.69915594.akpm@linux-foundation.org>
In-Reply-To: <4F9A0360.3030900@kernel.org>
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
	<4F963742.2030607@jp.fujitsu.com>
	<4F963B8E.9030105@kernel.org>
	<CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com>
	<4F965413.9010305@kernel.org>
	<CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
	<20120424143015.99fd8d4a.akpm@linux-foundation.org>
	<4F973BF2.4080406@jp.fujitsu.com>
	<CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com>
	<4F973FB8.6050103@jp.fujitsu.com>
	<20120424172554.c9c330dd.akpm@linux-foundation.org>
	<4F98914C.2060505@jp.fujitsu.com>
	<alpine.DEB.2.00.1204251715420.19452@chino.kir.corp.google.com>
	<4F9A0360.3030900@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 27 Apr 2012 11:24:32 +0900 Minchan Kim <minchan@kernel.org> wrote:

> I was about to add warning in __vmalloc internal if caller uses GFP_NOIO, GFP_NOFS, GFP_ATOMIC
> with Nick's comment and let them make to fix it. But it seems Andrew doesn't agree.

I do, actually.

> Andrew, please tell me your opinion for fixing this problem.

Only call vmalloc() from GFP_KERNEL contexts.  Go ahead, add the
WARN_ONCE() and let's see what happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

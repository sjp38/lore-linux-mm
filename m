Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E1EDF6B0087
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 21:00:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M10Wvv017979
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 22 Apr 2009 10:00:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CF7645DD75
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:00:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F15AE45DD74
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:00:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE3CB1DB8016
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:00:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A51351DB8019
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:00:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] mm tracepoints update
In-Reply-To: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com>
References: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20090422095916.627A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 22 Apr 2009 10:00:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mingo@elte.hu, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

> 
> I've cleaned up the mm tracepoints to track page allocation and
> freeing, various types of pagefaults and unmaps, and critical page
> reclamation routines.  This is useful for debugging memory allocation
> issues and system performance problems under heavy memory loads.

In past thread, Andrew pointed out bare page tracer isn't useful.
Can you make good consumer?


> 
> 
> ----------------------------------------------------------------------
> 
> 
> # tracer: mm
> #
> #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> #              | |       |          |         |
>          pdflush-624   [004]   184.293169: wb_kupdate:
> mm_pdflush_kupdate count=3e48
>          pdflush-624   [004]   184.293439: get_page_from_freelist:
> mm_page_allocation pfn=447c27 zone_free=1940910
>         events/6-33    [006]   184.962879: free_hot_cold_page:
> mm_page_free pfn=44bba9
>       irqbalance-8313  [001]   188.042951: unmap_vmas:
> mm_anon_userfree mm=ffff88044a7300c0 address=7f9a2eb70000 pfn=24c29a
>              cat-9122  [005]   191.141173: filemap_fault:
> mm_filemap_fault primary fault: mm=ffff88024c9d8f40 address=3cea2dd000
> pfn=44d68e
>              cat-9122  [001]   191.143036: handle_mm_fault:
> mm_anon_fault mm=ffff88024c8beb40 address=7fffbde99f94 pfn=24ce22
> -------------------------------------------------------------------------
> 
> Signed-off-by: Larry Woodman <lwoodman@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> 
> 
> The patch applies to ingo's latest tip tree:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

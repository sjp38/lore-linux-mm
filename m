Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4A4B66B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:34:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S9Ybhd012315
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 18:34:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCC245DE5C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 18:34:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9287645DE53
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 18:34:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 75DC41DB803F
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 18:34:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 05C301DB805F
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 18:34:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090428092918.GC21085@elte.hu>
References: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com> <20090428092918.GC21085@elte.hu>
Message-Id: <20090428183237.EBDE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 18:34:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
> > I have no idea how expensive tracepoints are but I suspect they 
> > don't make too much sense for this particular scenario. After all, 
> > kmemtrace is mainly interested in _allocation patterns_ whereas 
> > this patch seems to be more interested in "memory layout" type of 
> > things.
> 
> My point is that the allocation patterns can be derived from dynamic 
> events. We can build a map of everything if we know all the events 
> that led up to it. Doing:
> 
>   echo 3 > /proc/sys/vm/drop_caches
> 
> will clear 99% of the memory allocations, so we can build a new map 
> from scratch just about anytime. (and if boot allocations are 
> interesting they can be traced too)
> 
> _And_ via this angle we'll also have access to the dynamic events, 
> in a different 'view' of the same tracepoints - which is obviously 
> very useful for different purposes.

I am one of most strongly want guys to MM tracepoint.
but No, many cunstomer never permit to use drop_caches.

I believe this patch and tracepoint are _both_ necessary and useful.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

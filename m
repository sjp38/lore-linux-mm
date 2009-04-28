Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 61C076B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:10:20 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3SAASjd026911
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 19:10:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA91F45DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:10:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9727845DE50
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:10:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54AC11DB8040
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:10:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D89F1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:10:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
In-Reply-To: <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
References: <20090428093621.GD21085@elte.hu> <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
Message-Id: <20090428190822.EBED.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 19:10:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I guess the main question here is whether this approach will scale to
> something like kmalloc() or the page allocator in production
> environments. For any serious workload, the frequency of events is
> going to be pretty high.

Immediate Values patch series makes zero-overhead to tracepoint
while it's not used.

So, We have to implement to stop collect stastics way. it restore
zero overhead world.
We don't lose any performance by trace.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

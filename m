Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F3F4F6B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:10:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3SAB3r5027083
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 19:11:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B2FE45DD75
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:11:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 06DD645DD78
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:11:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A8C1DB8013
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:11:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4385BE08002
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:11:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090428095551.GB21168@localhost>
References: <20090428093833.GE21085@elte.hu> <20090428095551.GB21168@localhost>
Message-Id: <20090428190015.EBEA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 19:11:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > I am one of most strongly want guys to MM tracepoint. but No, many 
> > > cunstomer never permit to use drop_caches.
> > 
> > See my other mail i just sent: it would be a natural extension of 
> > tracing to also dump all current object state when tracing is turned 
> > on. That way no drop_caches is needed at all.
> 
> I can understand the merits here - I also did readahead
> tracing/accounting in _one_ piece of code. Very handy.
> 
> The readahead traces are now raw printks - converting to the ftrace
> framework would be a big win.
>
> But. It's still not a fit-all solution. Imagine when full data _since_
> booting is required, but the user cannot afford a reboot.
> 
> > But it has to be expressed in one framework that cares about the 
> > totality of the kernel - not just these splintered bits of 
> > instrumentation and pieces of statistics.
> 
> Though minded to push the kpageflags interface, I totally agree the
> above fine principle and discipline :-)

Yeah.
I totally agree your claim.

I'm interest to both ftrace based readahead tracer and this patch :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

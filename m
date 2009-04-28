Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DD6E96B0055
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 07:06:04 -0400 (EDT)
Date: Tue, 28 Apr 2009 13:05:53 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428110553.GD25347@elte.hu>
References: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com> <20090428092918.GC21085@elte.hu> <20090428183237.EBDE.A69D9226@jp.fujitsu.com> <20090428093833.GE21085@elte.hu> <20090428095551.GB21168@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428095551.GB21168@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Steven Rostedt <rostedt@goodmis.org>, =?utf-8?B?RnLpppjpp7tpYw==?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > See my other mail i just sent: it would be a natural extension 
> > of tracing to also dump all current object state when tracing is 
> > turned on. That way no drop_caches is needed at all.
> 
> I can understand the merits here - I also did readahead 
> tracing/accounting in _one_ piece of code. Very handy.
> 
> The readahead traces are now raw printks - converting to the 
> ftrace framework would be a big win.
> 
> But. It's still not a fit-all solution. Imagine when full data 
> _since_ booting is required, but the user cannot afford a reboot.

The above 'get object state' interface (which allows passive 
sampling) - integrated into the tracing framework - would serve that 
goal, agreed?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

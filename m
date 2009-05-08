Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB2C6B0093
	for <linux-mm@kvack.org>; Fri,  8 May 2009 16:31:34 -0400 (EDT)
Date: Fri, 8 May 2009 13:24:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-Id: <20090508132452.bafa287a.akpm@linux-foundation.org>
In-Reply-To: <20090508114742.GB17129@elte.hu>
References: <20090508105320.316173813@intel.com>
	<20090508111031.020574236@intel.com>
	<20090508114742.GB17129@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 May 2009 13:47:42 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Export all page flags faithfully in /proc/kpageflags.
> 
> Ongoing objection and NAK against extended haphazard exporting of 
> kernel internals via an ad-hoc ABI via ad-hoc, privatized 
> instrumentation that only helps the MM code and nothing else.

You're a year too late.  The pagemap interface is useful.

> /proc/kpageflags should be done via the proper methods outlined in 
> the previous mails i wrote on this topic: for example by using the 
> 'object collections' abstraction i suggested.

What's that?

> So this should be done in cooperation with instrumentation folks, 

Feel free to start cooperating.

> while improving _all_ of Linux instrumentation in general. Or, if 
> you dont have the time/interest to work with us on that, it should 
> not be done at all. Not having the resources/interest to do 
> something properly is not a license to introduce further 
> instrumentation crap into Linux.

If and when whatever-this-stuff-is is available and if it turns out to be
usable then someone can take on the task of migrating the existing
apgemap implementation over to use the new machinery while preserving
existing userspace interfaces.

But we shouldn't block improvements to an existing feature because
someone might change the way that feature is implemented some time in
the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

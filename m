Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AC54C6B004D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 08:44:41 -0400 (EDT)
Date: Fri, 8 May 2009 20:44:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090508124433.GB15949@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508114742.GB17129@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Fri, May 08, 2009 at 07:47:42PM +0800, Ingo Molnar wrote:
> 
> * Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Export all page flags faithfully in /proc/kpageflags.
> 
> Ongoing objection and NAK against extended haphazard exporting of 
> kernel internals via an ad-hoc ABI via ad-hoc, privatized 
> instrumentation that only helps the MM code and nothing else. It was 
> a mistake to introduce the /proc/kpageflags hack a year ago, and it 
> even more wrong today to expand on it.

If cannot abandon it, embrace it. That's my attitude.

> /proc/kpageflags should be done via the proper methods outlined in 
> the previous mails i wrote on this topic: for example by using the 
> 'object collections' abstraction i suggested. Clean enumeration of 
> all pages (files, tasks, etc.) and the definition of histograms over 
> it via free-form filter expressions is the right way to do this. It 
> would not only help other subsystems, it would also be far more 
> capable.

For the new interfaces(files etc.) I'd very like to use the ftrace
interface. For the existing pagemap interfaces, if they can fulfill
their targeted tasks, why bother making the shift?

When the pagemap interfaces cannot satisfy some new applications,
and ftrace can provide a superset of the pagemap interfaces and shows
clear advantages while meeting the new demands, then we can schedule
tearing down of the old interface?

> So this should be done in cooperation with instrumentation folks, 
> while improving _all_ of Linux instrumentation in general. Or, if 
> you dont have the time/interest to work with us on that, it should 
> not be done at all. Not having the resources/interest to do 
> something properly is not a license to introduce further 
> instrumentation crap into Linux.

I'd be glad to work with you on the 'object collections' ftrace
interfaces.  Maybe next month. For now my time have been allocated
for the hwpoison work, sorry!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

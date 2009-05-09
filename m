Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 185A56B00A1
	for <linux-mm@kvack.org>; Sat,  9 May 2009 01:58:41 -0400 (EDT)
Date: Sat, 9 May 2009 07:59:14 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090509055914.GA21354@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508124433.GB15949@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> > /proc/kpageflags should be done via the proper methods outlined 
> > in the previous mails i wrote on this topic: for example by 
> > using the 'object collections' abstraction i suggested. Clean 
> > enumeration of all pages (files, tasks, etc.) and the definition 
> > of histograms over it via free-form filter expressions is the 
> > right way to do this. It would not only help other subsystems, 
> > it would also be far more capable.
> 
> For the new interfaces(files etc.) I'd very like to use the ftrace 
> interface. For the existing pagemap interfaces, if they can 
> fulfill their targeted tasks, why bother making the shift?

Because they were a mistake to be merged? Because having them 
fragments and thus weakens Linux instrumentation in general? 
Because, somewhat hipocritically, other MM instrumentation patches 
are being rejected under the pretense that they "do not matter" - 
while instrumentation that provably _does_ matter (yours) is added 
outside the existing instrumentation frameworks?

> When the pagemap interfaces cannot satisfy some new applications, 
> and ftrace can provide a superset of the pagemap interfaces and 
> shows clear advantages while meeting the new demands, then we can 
> schedule tearing down of the old interface?

Yes. But meanwhile dont extend it ... otherwise this bad cycle will 
never end. "Oh, we just added this to /proc/kpageflags too, why 
should we go through the trouble of use the generic framework?"

Do you see my position?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

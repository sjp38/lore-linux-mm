Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 512036B00AF
	for <linux-mm@kvack.org>; Sat,  9 May 2009 05:24:28 -0400 (EDT)
Date: Sat, 9 May 2009 11:24:31 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] tracing/mm: add page frame snapshot trace
Message-ID: <20090509092431.GB13784@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508124433.GB15949@localhost> <20090509062758.GB21354@elte.hu> <20090509091325.GA7994@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509091325.GA7994@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> Hi Ingo,
> 
> On Sat, May 09, 2009 at 02:27:58PM +0800, Ingo Molnar wrote:
> > 
> > * Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > > So this should be done in cooperation with instrumentation 
> > > > folks, while improving _all_ of Linux instrumentation in 
> > > > general. Or, if you dont have the time/interest to work with us 
> > > > on that, it should not be done at all. Not having the 
> > > > resources/interest to do something properly is not a license to 
> > > > introduce further instrumentation crap into Linux.
> > > 
> > > I'd be glad to work with you on the 'object collections' ftrace 
> > > interfaces.  Maybe next month. For now my time have been allocated 
> > > for the hwpoison work, sorry!
> > 
> > No problem - our offer still stands: we are glad to help out with 
> > the instrumentation side bits. We'll even write all the patches for 
> > you, just please help us out with making it maximally useful to 
> > _you_ :-)
> 
> Thank you very much!
> 
> The good fact is, 2/3 of the code and experiences can be reused.
> 
> > Find below a first prototype patch written by Steve yesterday and 
> > tidied up a bit by me today. It can also be tried on latest -tip:
> > 
> >   http://people.redhat.com/mingo/tip.git/README
> > 
> > This patch adds the first version of the 'object collections' 
> > instrumentation facility under /debug/tracing/objects/mm/. It has a 
> > single control so far, a 'number of pages to dump' trigger file:
> > 
> > To dump 1000 pages to the trace buffers, do:
> > 
> >   echo 1000 > /debug/tracing/objects/mm/pages/trigger
> > 
> > To dump all pages to the trace buffers, do:
> > 
> >   echo -1 > /debug/tracing/objects/mm/pages/trigger
> 
> That is not too intuitive, I'm afraid.

This was just a first-level approximation - and it matches the usual 
"0xffffffff means infinite" idiom.

How about changing it from 'trigger' to 'dump_range':

   echo "*" > /debug/tracing/objects/mm/pages/dump_range

being a shortcut for 'dump all'?

And:

   echo "1000 2000" > /debug/tracing/objects/mm/pages/dump_range

?

The '1000' is the offset where the dumping starts, and 2000 is the 
size of the dump.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

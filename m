Subject: Re: 2.5.65-mm2
From: "Steven P. Cole" <elenstev@mesatop.com>
Reply-To: elenstev@mesatop.com
In-Reply-To: <5.2.0.9.2.20030320220413.00ceaa98@pop.gmx.net>
References: <5.2.0.9.2.20030320194530.01985440@pop.gmx.net>
	 <200303192327.45883.tomlins@cam.org>
	 <20030319012115.466970fd.akpm@digeo.com>
	 <20030319163337.602160d8.akpm@digeo.com>
	 <1048117516.1602.6.camel@spc1.esa.lanl.gov>
	 <200303192327.45883.tomlins@cam.org>
	 <5.2.0.9.2.20030320194530.01985440@pop.gmx.net>
	 <5.2.0.9.2.20030320220413.00ceaa98@pop.gmx.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Message-Id: <1048194922.1639.40.camel@spc1.esa.lanl.gov>
Mime-Version: 1.0
Date: 20 Mar 2003 14:15:22 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Ed Tomlinson <tomlins@cam.org>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-03-20 at 14:07, Mike Galbraith wrote:
> At 01:12 PM 3/20/2003 -0700, Steven P. Cole wrote:
> >On Thu, 2003-03-20 at 12:48, Mike Galbraith wrote:
> > > At 07:36 AM 3/20/2003 -0700, Steven Cole wrote:
> > > Bottom line is that once cpu hogs are falsely determined to be sleepers,
> > > positive feedback kills you.
> > >
> > >          -Mike
> > >
> > >
> >Sure, either post a patch against a known sync point, .65, .65-bk, or
> >65-mm2, or send me the sched.c file itself (2600 lines might be a little
> >too much for the entire list).
> >
> >If you send it in the next 2 hours, I can test today, otherwise I'll do
> >it manana.
> 
> What the heck.  It is attached.
> 
>          -Mike
> 
> (and I repeat, don't _look_, just run it, and let me know;) 

[steven@spc1 linux-2.5.65-mg]$ patch -p1 <../../xx.diff
patching file include/linux/sched.h
patching file kernel/fork.c
patching file kernel/printk.c
patching file kernel/sched.c
patch: **** unexpected end of file in patch

It looks like the last hunk has no trailing context lines.
Did your patch get clobbered?

Steven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

Date: Thu, 7 Jun 2001 06:32:42 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Break 2.4 VM in five easy steps
In-Reply-To: <m1k82p5rxr.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33.0106070631150.285-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Derek Glidden <dglidden@illusionary.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6 Jun 2001, Eric W. Biederman wrote:

> Mike Galbraith <mikeg@wen-online.de> writes:
>
> > > If you could confirm this by calling swapoff sometime other than at
> > > reboot time.  That might help.  Say by running top on the console.
> >
> > The thing goes comatose here too. SCHED_RR vmstat doesn't run, console
> > switch is nogo...
> >
> > After running his memory hog, swapoff took 18 seconds.  I hacked a
> > bleeder valve for dead swap pages, and it dropped to 4 seconds.. still
> > utterly comatose for those 4 seconds though.
>
> At the top of the while(1) loop in try_to_unuse what happens if you put in.
> if (need_resched) schedule();
> It should be outside all of the locks.  It might just be a matter of everything
> serializing on the SMP locks, and the kernel refusing to preempt itself.

That did it.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

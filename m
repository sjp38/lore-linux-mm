Date: Thu, 7 Jun 2001 09:28:58 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Break 2.4 VM in five easy steps
In-Reply-To: <m1bso06bgu.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33.0106070926400.6078-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Derek Glidden <dglidden@illusionary.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 Jun 2001, Eric W. Biederman wrote:

> Mike Galbraith <mikeg@wen-online.de> writes:
>
> > On 6 Jun 2001, Eric W. Biederman wrote:
> >
> > > Mike Galbraith <mikeg@wen-online.de> writes:
> > >
> > > > > If you could confirm this by calling swapoff sometime other than at
> > > > > reboot time.  That might help.  Say by running top on the console.
> > > >
> > > > The thing goes comatose here too. SCHED_RR vmstat doesn't run, console
> > > > switch is nogo...
> > > >
> > > > After running his memory hog, swapoff took 18 seconds.  I hacked a
> > > > bleeder valve for dead swap pages, and it dropped to 4 seconds.. still
> > > > utterly comatose for those 4 seconds though.
> > >
> > > At the top of the while(1) loop in try_to_unuse what happens if you put in.
> > > if (need_resched) schedule();
> > > It should be outside all of the locks.  It might just be a matter of
> > everything
> >
> > > serializing on the SMP locks, and the kernel refusing to preempt itself.
> >
> > That did it.
>
> Does this improve the swapoff speed or just allow other programs to
> run at the same time?  If it is still slow under that kind of load it
> would be interesting to know what is taking up all time.
>
> If it is no longer slow a patch should be made and sent to Linus.

No, it only cures the freeze.  The other appears to be the slow code
pointed out by Andrew Morton being tickled by dead swap pages.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

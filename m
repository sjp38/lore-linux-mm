Date: Sat, 6 Nov 2004 15:48:58 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: manual page migration, revisited...
Message-ID: <20041106174857.GA23420@logos.cnet>
References: <418C03CD.2080501@sgi.com> <1099695742.4507.114.camel@desktop.cunninghams>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1099695742.4507.114.camel@desktop.cunninghams>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@linuxmail.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 10:02:22AM +1100, Nigel Cunningham wrote:
> Hi.
> 
> On Sat, 2004-11-06 at 09:50, Ray Bryant wrote:
> > Marcelo and Takahashi-san (and anyone else who would like to comment),
> > 
> > This is a little off topic, but this is as good of thread as any to start this 
> > discussion on.  Feel free to peel this off as a separate discussion thread 
> > asap if you like.
> > 
> > We have a requirement (for a potential customer) to do the following kind of
> > thing:
> > 
> > (1)  Suspend and swap out a running process so that the node where the process
> >       is running can be reassigned to a higher priority job.
> > 
> > (2)  Resume and swap back in those suspended jobs, restoring the original
> >       memory layout on the original nodes, or
> > 
> > (3)  Resume and swap back in those suspended jobs on a new set of nodes, with
> >       as similar topological layout as possible.  (It's also possible we may
> >       want to just move the jobs directly from one set of nodes to another
> >       without swapping them out first.
> 
> You may not even need any kernel patches to accomplish this. Bernard
> Blackham wrote some code called cryopid: http://cryopid.berlios.de/. I
> haven't tried it myself, but it sounds like it might be at least part of
> what you're after.

Hi Ray, Nigel,

And the swsusp code itself, isnt it what its doing? Stopping all processes, 
saving their memory to disk, and resuming later on.

You should just need an API to stop a specific process? 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: manual page migration, revisited...
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <20041106174857.GA23420@logos.cnet>
References: <418C03CD.2080501@sgi.com>
	 <1099695742.4507.114.camel@desktop.cunninghams>
	 <20041106174857.GA23420@logos.cnet>
Content-Type: text/plain
Message-Id: <1099796318.3811.9.camel@desktop.cunninghams>
Mime-Version: 1.0
Date: Sun, 07 Nov 2004 13:58:38 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Sun, 2004-11-07 at 04:48, Marcelo Tosatti wrote:
> On Sat, Nov 06, 2004 at 10:02:22AM +1100, Nigel Cunningham wrote:
> > On Sat, 2004-11-06 at 09:50, Ray Bryant wrote:
> > > Marcelo and Takahashi-san (and anyone else who would like to comment),
> > > 
> > > This is a little off topic, but this is as good of thread as any to start this 
> > > discussion on.  Feel free to peel this off as a separate discussion thread 
> > > asap if you like.
> > > 
> > > We have a requirement (for a potential customer) to do the following kind of
> > > thing:
> > > 
> > > (1)  Suspend and swap out a running process so that the node where the process
> > >       is running can be reassigned to a higher priority job.
> > > 
> > > (2)  Resume and swap back in those suspended jobs, restoring the original
> > >       memory layout on the original nodes, or
> > > 
> > > (3)  Resume and swap back in those suspended jobs on a new set of nodes, with
> > >       as similar topological layout as possible.  (It's also possible we may
> > >       want to just move the jobs directly from one set of nodes to another
> > >       without swapping them out first.
> > 
> > You may not even need any kernel patches to accomplish this. Bernard
> > Blackham wrote some code called cryopid: http://cryopid.berlios.de/. I
> > haven't tried it myself, but it sounds like it might be at least part of
> > what you're after.
> 
> Hi Ray, Nigel,
> 
> And the swsusp code itself, isnt it what its doing? Stopping all processes, 
> saving their memory to disk, and resuming later on.

Software suspend does the whole machine; I was understanding, perhaps
wrongly, that Ray only wants to move particular processes.

> You should just need an API to stop a specific process? 

(And save it's state).

Regards,

Nigel
-- 
Nigel Cunningham
Pastoral Worker
Christian Reformed Church of Tuggeranong
PO Box 1004, Tuggeranong, ACT 2901

You see, at just the right time, when we were still powerless, Christ
died for the ungodly.		-- Romans 5:6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

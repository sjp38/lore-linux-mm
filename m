Date: Sun, 8 Jun 2008 16:54:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-Id: <20080608165434.67c87e5c.akpm@linux-foundation.org>
In-Reply-To: <20080608193420.2a9cc030@bree.surriel.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 19:34:20 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Sun, 8 Jun 2008 16:22:08 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > The this-is-64-bit-only problem really sucks, IMO.  We still don't know
> > the reason for that decision.  Presumably it was because we've already
> > run out of page flags?  If so, the time for the larger pageframe is
> > upon us.
> 
> 32 bit machines are unlikely to have so much memory that they run
> into big scalability issues with mlocked memory.
> 
> The obvious exception to that are large PAE systems, which run
> into other bottlenecks already and will probably hit the wall in
> some other way before suffering greatly from the "kswapd is
> scanning unevictable pages" problem.
> 
> I'll leave it up to you to decide whether you want this feature
> 64 bit only, or whether you want to use up the page flag on 32
> bit systems too.
> 
> Please let me know which direction I should take, so I can fix
> up the patch set accordingly.

I'm getting rather wobbly about all of this.

This is, afair, by far the most intrusive and high-risk change we've
looked at doing since 2.5.x, for small values of x.

I mean, it's taken many years of work to get reclaim into its current
state (and the reduction in reported problems will in part be due to
the quadrupling-odd of memory over that time).  And we're now proposing
radical changes which again will take years to sort out, all on behalf
of a small number of workloads upon a minority of 64-bit machines which
themselves are a minority of the Linux base.

And it will take longer to get those problems sorted out if 32-bt
machines aren't even compiing the new code in.

Are all of thse changes really justified?

ho hum.  Can you remind us what problems this patchset actually
addresses?  Preferably in order of seriousness?  (The [0/n] description
told us about the implementation but forgot to tell us anything about
what it was fixing).  Because I guess we should have a think about
alternative approaches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 26 Apr 2000 13:29:15 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426132915.J3792@redhat.com>
References: <20000426120130.E3792@redhat.com> <Pine.LNX.4.21.0004260814130.16202-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004260814130.16202-100000@duckman.conectiva>; from riel@conectiva.com.br on Wed, Apr 26, 2000 at 08:15:14AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Simon Kirby <sim@stormix.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 08:15:14AM -0300, Rik van Riel wrote:
> On Wed, 26 Apr 2000, Stephen C. Tweedie wrote:
> > On Tue, Apr 25, 2000 at 12:06:58PM -0700, Simon Kirby wrote:
> > > 
> > > Sorry, I made a mistake there while writing..I was going to give an
> > > example and wrote 60 seconds, but I didn't actually mean to limit
> > > anything to 60 seconds.  I just meant to make a really big global lru
> > > that contains everything including page cache and swap. :)
> > 
> > Doesn't work.  If you do that, a "find / | grep ..." swaps out 
> > everything in your entire system.
> > 
> > Getting the VM to respond properly in a way which doesn't freak out
> > in the mass-filescan case is non-trivial.  Simple LRU over all pages
> > simply doesn't cut it.
> 
> It seems to work pretty well, because pages "belonging to" processes
> are mapped into the address space of each process and will never go
> through swap_out() if shrink_mmap() will succeed.

I know.  The post wasn't talking about what we do now.  It was talking
about a hypothetical LRU which covers "everything including page cache
and swap."  LRU over just the page cache pages works fine.  If you 
start treating swap exactly the same, on a page-by-page LRU, then a
filesystem "find" scan will swap out most of your VM.  Bad news.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

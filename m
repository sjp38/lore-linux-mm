Subject: Re: [PATCH] vma limited swapin readahead
References: <Pine.LNX.4.21.0101310636530.16408-100000@freak.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 31 Jan 2001 12:40:52 -0700
In-Reply-To: Marcelo Tosatti's message of "Wed, 31 Jan 2001 06:40:18 -0200 (BRST)"
Message-ID: <m18znrcxx7.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On Wed, 31 Jan 2001, Stephen C. Tweedie wrote:
> 
> > Hi,
> > 
> > On Wed, Jan 31, 2001 at 01:05:02AM -0200, Marcelo Tosatti wrote:
> > > 
> > > However, the pages which are contiguous on swap are not necessarily
> > > contiguous in the virtual memory area where the fault happened. That means
> > > the swapin readahead code may read pages which are not related to the
> > > process which suffered a page fault.
> > > 
> > Yes, but reading extra sectors is cheap, and throwing the pages out of
> > memory again if they turn out not to be needed is also cheap.  The
> > on-disk swapped pages are likely to have been swapped out at roughly
> > the same time, which is at least a modest indicator of being of the
> > same age and likely to have been in use at the same time in the past.
> 
> You're throwing away pages from memory to do the readahead. 
> 
> This pages might be more useful than the pages which you're reading from
> swap. 

Possibly.  However the win (lower latency) from getting swapin
readahead is probably even bigger.  And you are throwing out the least
desirable pages in memory.

> > I'd like to see at lest some basic performance numbers on this,
> > though.
> 
> I'm not sure if limiting the readahead the way my patch does is a better
> choice, too.

A better choice is probably to make certain the read and write paths are in
sync so that you can know the readahead is going to do you some good.
This is a little tricky though.  

Unless you can see a big performance win somewhere please don't submit
this to Linus for inclusion.


Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

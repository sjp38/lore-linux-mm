Date: Wed, 31 Jan 2001 06:40:18 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] vma limited swapin readahead
In-Reply-To: <20010131102158.O11607@redhat.com>
Message-ID: <Pine.LNX.4.21.0101310636530.16408-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jan 2001, Stephen C. Tweedie wrote:

> Hi,
> 
> On Wed, Jan 31, 2001 at 01:05:02AM -0200, Marcelo Tosatti wrote:
> > 
> > However, the pages which are contiguous on swap are not necessarily
> > contiguous in the virtual memory area where the fault happened. That means
> > the swapin readahead code may read pages which are not related to the
> > process which suffered a page fault.
> > 
> Yes, but reading extra sectors is cheap, and throwing the pages out of
> memory again if they turn out not to be needed is also cheap.  The
> on-disk swapped pages are likely to have been swapped out at roughly
> the same time, which is at least a modest indicator of being of the
> same age and likely to have been in use at the same time in the past.

You're throwing away pages from memory to do the readahead. 

This pages might be more useful than the pages which you're reading from
swap. 

> I'd like to see at lest some basic performance numbers on this,
> though.

I'm not sure if limiting the readahead the way my patch does is a better
choice, too.

I posted it to lkml so people can test it under different workloads and
report results.

Thanks for your feedback. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

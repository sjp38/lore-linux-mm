Date: Thu, 8 Mar 2001 19:47:59 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: nr_async_pages and swapin readahead on -ac series
In-Reply-To: <20010308201714.O10437@redhat.com>
Message-ID: <Pine.LNX.4.21.0103081944560.2336-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Mar 2001, Stephen C. Tweedie wrote:

> Hi,
> 
> On Wed, Mar 07, 2001 at 10:57:21PM -0300, Marcelo Tosatti wrote:
> >  
> > On the latest 2.4 -ac series, nr_async_pages is only being used to count
> > swap outs, and not for both swap reads and writes (as Linus tree does).
> 
> Seems fine to me.
> 
> > The problem is that nr_async_pages is used to limit swapin readahead based
> > on the number of on flight swap pages (mm/memory.c::swapin_readahead):
> 
> That's probably a mistake: we don't throttle readahead on normal files
> in this manner.
> 
> Swapin is always synchronous: it happens in response to a task's page
> fault.  As such it is always going to be rate-limited automatically.
> I don't think it's too important to count reads in nr_async_pages, nor
> to throttle readaheads if nr_async_pages is too large.

Its not really throttling. We just _bypass_ the readahead's in case we got
too much. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

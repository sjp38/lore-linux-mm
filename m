Date: Fri, 9 Mar 2001 11:02:16 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: nr_async_pages and swapin readahead on -ac series
Message-ID: <20010309110216.B11513@redhat.com>
References: <20010308201714.O10437@redhat.com> <Pine.LNX.4.21.0103081944560.2336-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0103081944560.2336-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, Mar 08, 2001 at 07:47:59PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Mar 08, 2001 at 07:47:59PM -0300, Marcelo Tosatti wrote:
> 
> > Swapin is always synchronous: it happens in response to a task's page
> > fault.  As such it is always going to be rate-limited automatically.
> > I don't think it's too important to count reads in nr_async_pages, nor
> > to throttle readaheads if nr_async_pages is too large.
> 
> Its not really throttling. We just _bypass_ the readahead's in case we got
> too much. 

I know, but I still think it's worth doing the readahead in any case.
We've got 8192 request slots per swap device so we're not going to
suddenly go synchronous because of readahead, and the callers are
naturally throttled (because they wait synchronously on the requested
page) so we don't have to worry about submitting unbounded IO.

An extra seek is _so_ much more expensive than the
readahead/readaround that I doubt it's worth making it conditional.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

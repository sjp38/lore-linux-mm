Date: Thu, 8 Mar 2001 20:17:14 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: nr_async_pages and swapin readahead on -ac series
Message-ID: <20010308201714.O10437@redhat.com>
References: <Pine.LNX.4.21.0103072241130.1268-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0103072241130.1268-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Wed, Mar 07, 2001 at 10:57:21PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 07, 2001 at 10:57:21PM -0300, Marcelo Tosatti wrote:
>  
> On the latest 2.4 -ac series, nr_async_pages is only being used to count
> swap outs, and not for both swap reads and writes (as Linus tree does).

Seems fine to me.

> The problem is that nr_async_pages is used to limit swapin readahead based
> on the number of on flight swap pages (mm/memory.c::swapin_readahead):

That's probably a mistake: we don't throttle readahead on normal files
in this manner.

Swapin is always synchronous: it happens in response to a task's page
fault.  As such it is always going to be rate-limited automatically.
I don't think it's too important to count reads in nr_async_pages, nor
to throttle readaheads if nr_async_pages is too large.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

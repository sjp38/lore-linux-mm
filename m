Date: Wed, 7 Jun 2000 15:43:50 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
Message-ID: <20000607154350.N30951@redhat.com>
References: <Pine.LNX.4.21.0006071025330.14304-100000@duckman.distro.conectiva> <qww7lc1pnt0.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qww7lc1pnt0.fsf@sap.com>; from cr@sap.com on Wed, Jun 07, 2000 at 04:29:15PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 04:29:15PM +0200, Christoph Rohland wrote:

> > 2) we need to be able to swap out shm pages (maybe just
> >    call a page->mapping->swapout() function?) by knowing just
> >    the page
> 
> This is not that easy. I need a backreference to the shm segment and
> the index into it to be able to note the new pte entry. Do you know
> where we could put these?

It's also trivial: just maintain a struct address_space for each
shm segment, and put the shm segment address in the address_space->
host field.  Index each shm page against that address_space and
the VM will be able to find you for any callbacks it needs to make,
and you will be able to find the shm segment from that.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

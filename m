Date: Thu, 26 Oct 2000 16:58:21 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: ptes flags in compressed cache
Message-ID: <20001026165821.W20050@redhat.com>
References: <20001026135245.B19100@linux.ime.usp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001026135245.B19100@linux.ime.usp.br>; from rcastro@linux.ime.usp.br on Thu, Oct 26, 2000 at 01:52:45PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rodrigo S. de Castro" <rcastro@linux.ime.usp.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 26, 2000 at 01:52:45PM -0200, Rodrigo S. de Castro wrote:
> 
> 	I am working on a compressed cache for 2.2.16 and I am
> currently in a cache with no compression implementation. Well, at this
> step, I gotta a doubt of how can I mark the pages (actually, ptes)
> that are in my cache and neither present in memory nor in swap. This
> is essential when I have a page fault, and this page is not present in
> memory.

Reserve a SWP_ENTRY for compressed pages.  There's precedent for that:
SHM in 2.2 already uses that mechanism for swapped-out shared memory
pages.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

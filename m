Date: Mon, 12 Jun 2000 23:29:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
Message-ID: <20000612232932.I15054@redhat.com>
References: <87ln0abmji.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ln0abmji.fsf@atlas.iskon.hr>; from zlatko@iskon.hr on Mon, Jun 12, 2000 at 11:46:09PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jun 12, 2000 at 11:46:09PM +0200, Zlatko Calusic wrote:
> 
> This simple one-liner solves a long standing problem in Linux VM.
> While searching for a discardable page in shrink_mmap() Linux was too
> easily failing and subsequently falling back to swapping. The problem
> was that shrink_mmap() counted pages from the wrong zone, and in case
> of balancing a relatively smaller zone (e.g. DMA zone on a 128MB
> computer) "count" would be mistakenly spent dealing with pages from
> the wrong zone. The net effect of all this was spurious swapping that
> hurt performance greatly.

Nice --- it might also explain some of the excessive kswap CPU 
utilisation we've seen reported now and again.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Subject: Re: [PATCH] boobytrap for 2.2.15pre5
Date: Fri, 28 Jan 2000 14:31:22 +0000 (GMT)
In-Reply-To: <XFMail.20000128103339.gale@syntax.dera.gov.uk> from "Tony Gale" at Jan 28, 2000 10:33:39 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12ECQo-0004s2-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Gale <gale@syntax.dera.gov.uk>
Cc: Rik van Riel <riel@nl.linux.org>, Linux MM <linux-mm@kvack.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

> c014d30c T sk_alloc
> c014db40 T alloc_skb
> c014dd04 T skb_clone

That path is easy - tcp_connect(). Looks like NFS is being naughty
> 
> c015c438 T tcp_timewait_state_process
> c015c528 T tcp_time_wait

This one makes no sense: its
	tw = kmem_cache_alloc(tcp_timewait_cachep, SLAB_ATOMIC); 

Looking harder I think Rik overdid the debugging checks.

Time for round two on these


Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 124226B0062
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 20:44:25 -0400 (EDT)
Date: Wed, 6 Jun 2012 20:37:20 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: frontswap: is frontswap_init called from swapoff safe?
Message-ID: <20120607003720.GI9472@phenom.dumpdata.com>
References: <4FCDE270.1020906@cesarb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FCDE270.1020906@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Tue, Jun 05, 2012 at 07:41:52AM -0300, Cesar Eduardo Barros wrote:
> I was looking at the swapfile.c parts of the recently-merged
> frontswap, and noticed that frontswap_init can be called from
> swapoff when try_to_unuse fails.
> 
> This looks odd to me. Whether it is safe or not depends on what
> frontswap_ops.init does, but the comment for __frontswap_init
> ("Called when a swap device is swapon'd") and the function name
> itself seem to imply it should be called only for swapon, not when
> relinking the swap_info after a failed swapoff.

<nods>
> 
> In particular, if frontswap_ops.init assumes the swap map is empty,
> it would break, since as far as I know when try_to_unuse fails there
> are still pages in the swap.

Let me look at this - can't do it this week - but will get back to you
shortly.
> 
> (By the way, the comment above enable_swap_info at sys_swapoff needs
> to be updated to also explain why reading p->frontswap_map outside
> the lock is safe at that point, like it does for p->prio and
> p->swap_map.)
> 
> -- 
> Cesar Eduardo Barros
> cesarb@cesarb.net
> cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 16 Aug 2004 16:29:42 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: use for page_state accounting fields
Message-ID: <20040816192941.GB21238@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I suppose you wrote the page_state per-CPU statistics structure.

There are some fields, for instance pgactivate/pgdeactivate, that
do not seem to be used anywhere. Sure, they are useful for statistics, 
but no place in the kernel exports them to userspace AFAICS.

        unsigned long pgactivate;       /* pages moved inactive->active */
        unsigned long pgdeactivate;     /* pages moved active->inactive */

Counting them is somewhat expensive I believe (need to disable IRQ), based
on the assumption that these days any cycle is a loss.

So, from my POV we should 

a) export them to userspace
b) surround them by CONFIG_DEBUG_MMSTATS or something similar

Tell me I'm wrong.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 13 Feb 2004 01:47:29 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.6.3-rc2-mm1
Message-ID: <20040212144729.GI25922@krispykreme>
References: <20040212015710.3b0dee67.akpm@osdl.org> <20040212031322.742b29e7.akpm@osdl.org> <20040212115718.GF25922@krispykreme> <20040212040910.3de346d4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040212040910.3de346d4.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > A few questions spring to mind. Like who wrote that dodgy patch? 
> The dog wrote my homework?

> > And any ideas how said person (who will remain nameless) broke ia32?
> Not really.  I spent a couple of hours debugging the darn thing, then gave
> up and used binary search to find the offending patch.

Ouch, you'll never get those hours back and you have me to thank for it.

> <looks>
> include/asm-i386/hardirq.h:IRQ_EXIT_OFFSET needs treatment, I bet.  

Yep. I wonder why DEBUG_SPINLOCK_SLEEP didnt depend on PREEMPT.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

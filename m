Date: Thu, 12 Feb 2004 04:09:10 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc2-mm1
Message-Id: <20040212040910.3de346d4.akpm@osdl.org>
In-Reply-To: <20040212115718.GF25922@krispykreme>
References: <20040212015710.3b0dee67.akpm@osdl.org>
	<20040212031322.742b29e7.akpm@osdl.org>
	<20040212115718.GF25922@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton Blanchard <anton@samba.org> wrote:
>
>  
> > This kernel and also 2.6.3-rc1-mm1 have a nasty bug which causes
> > current->preempt_count to be decremented by one on each hard IRQ.  It
> > manifests as a BUG() in the slab code early in boot.
> > 
> > Disabling CONFIG_DEBUG_SPINLOCK_SLEEP will fix this up.  Do not use this
> > feature on ia32, for it is bust.
> 
> A few questions spring to mind. Like who wrote that dodgy patch? 

The dog wrote my homework?

> And any ideas how said person (who will remain nameless) broke ia32?

Not really.  I spent a couple of hours debugging the darn thing, then gave
up and used binary search to find the offending patch.

<looks>

include/asm-i386/hardirq.h:IRQ_EXIT_OFFSET needs treatment, I bet.  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Thu, 12 Feb 2004 22:57:18 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.6.3-rc2-mm1
Message-ID: <20040212115718.GF25922@krispykreme>
References: <20040212015710.3b0dee67.akpm@osdl.org> <20040212031322.742b29e7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040212031322.742b29e7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> This kernel and also 2.6.3-rc1-mm1 have a nasty bug which causes
> current->preempt_count to be decremented by one on each hard IRQ.  It
> manifests as a BUG() in the slab code early in boot.
> 
> Disabling CONFIG_DEBUG_SPINLOCK_SLEEP will fix this up.  Do not use this
> feature on ia32, for it is bust.

A few questions spring to mind. Like who wrote that dodgy patch? 
And any ideas how said person (who will remain nameless) broke ia32?

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

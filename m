Date: Thu, 12 Feb 2004 03:13:22 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc2-mm1
Message-Id: <20040212031322.742b29e7.akpm@osdl.org>
In-Reply-To: <20040212015710.3b0dee67.akpm@osdl.org>
References: <20040212015710.3b0dee67.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/

This kernel and also 2.6.3-rc1-mm1 have a nasty bug which causes
current->preempt_count to be decremented by one on each hard IRQ.  It
manifests as a BUG() in the slab code early in boot.

Disabling CONFIG_DEBUG_SPINLOCK_SLEEP will fix this up.  Do not use this
feature on ia32, for it is bust.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

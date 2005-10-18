Date: Mon, 17 Oct 2005 18:04:51 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
Message-Id: <20051017180451.358f9dcc.akpm@osdl.org>
In-Reply-To: <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
	<20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> +		write_lock_irq(&mapping->tree_lock);
>  +
>  +		if (page_count(page) != 2 || PageDirty(page)) {
>  +			write_unlock_irq(&mapping->tree_lock);
>  +			goto retry_later_locked;
>  +		}

This needs the (uncommented (grr)) smp_rmb() copied-and-pasted as well.

It's a shame about the copy-and-pasting :(   Is it unavoidable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

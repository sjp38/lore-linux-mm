Date: Thu, 20 Apr 2006 18:22:40 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/5] mm: deprecate vmalloc_to_pfn
Message-ID: <20060420172240.GD21659@infradead.org>
References: <20060228202202.14172.60409.sendpatchset@linux.site> <20060228202223.14172.21110.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060228202223.14172.21110.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 20, 2006 at 07:06:30PM +0200, Nick Piggin wrote:
> Deprecate vmalloc_to_pfn.

I don't think there's any point to even keep it.  There's a trivial replcement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

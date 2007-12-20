Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1198163908.6821.33.camel@twins>
References: <1198155938.6821.3.camel@twins>
	 <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
	 <1198162078.6821.27.camel@twins>  <1198162560.6821.30.camel@twins>
	 <1198163908.6821.33.camel@twins>
Content-Type: text/plain
Date: Thu, 20 Dec 2007 16:23:39 +0100
Message-Id: <1198164219.6821.36.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 16:18 +0100, Peter Zijlstra wrote:

> +static int madvise_willneed_anon_pte(pte_t *ptep,
> +		unsigned long start, unsigned long end, void *arg)
> +{
> +	struct vm_area_struct *vma = arg;
> +	struct page *page;
> +
> +	page = read_swap_cache_async(pte_to_swp_entry(*ptep), GFP_KERNEL,

Argh, with HIGHPTE this is done inside a kmap_atomic.

/me goes complicate the code with page pre-allocation..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

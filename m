Date: Thu, 23 Jun 2005 00:26:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch][rfc] 2/5: micro optimisation for mm/rmap.c
Message-ID: <20050623072609.GA3334@holomorphy.com>
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BA5F7B.30904@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 23, 2005 at 05:06:35PM +1000, Nick Piggin wrote:
> +		index = (address - vma->vm_start) >> PAGE_SHIFT;
> +		index += vma->vm_pgoff;
> +		index >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
> +		page->index = index;

linear_page_index()


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

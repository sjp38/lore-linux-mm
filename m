Date: Fri, 21 Apr 2006 00:17:12 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-Id: <20060421001712.4cd5625e.akpm@osdl.org>
In-Reply-To: <20060301045910.12434.4844.sendpatchset@linux.site>
References: <20060301045901.12434.54077.sendpatchset@linux.site>
	<20060301045910.12434.4844.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
> Add a remap_vmalloc_range and get rid of as many remap_pfn_range and
> vm_insert_page loops as possible.
> 
> remap_vmalloc_range can do a whole lot of nice range checking even
> if the caller gets it wrong (which it looks like one or two do).
> 
> 
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED))
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED))
> -		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED))
> -		if (remap_pfn_range(vma, start, page + vma->vm_pgoff,
> -						PAGE_SIZE, vma->vm_page_prot))
> -		if (remap_pfn_range(vma, addr, pfn, PAGE_SIZE, PAGE_READONLY))

You've removed the ability for the caller to set the pte protections - it
now always uses vma->vm_page_prot.

please explain...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

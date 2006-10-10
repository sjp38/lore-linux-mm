Date: Tue, 10 Oct 2006 15:33:42 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc] 2.6.19-rc1-git5: consolidation of file backed fault handlers
Message-ID: <20061010143342.GA5580@infradead.org>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061010121314.19693.75503.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 04:21:32PM +0200, Nick Piggin wrote:
> This patchset is against 2.6.19-rc1-mm1 up to
> numa-add-zone_to_nid-function-swap_prefetch.patch (ie. no readahead stuff,
> which causes big rejects and would be much easier to fix in readahead
> patches than here). Other than this feature, the -mm specific stuff is
> pretty simple (mainly straightforward filesystem conversions).
> 
> Changes since last round:
> - trimmed the cc list, no big changes since last time.
> - fix the few buglets preventing it from actually booting
> - reinstate filemap_nopage and filemap_populate, because they're exported
>   symbols even though no longer used in the tree. Schedule for removal.

Just kill them and the whole ->populate methods.  We have a better API that
replaces them 100% with your patch, and they've never been a widespread
API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

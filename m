Date: Fri, 4 Apr 2003 08:14:57 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030404161457.GE993@holomorphy.com>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, Dave McCracken <dmccr@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2003 at 03:34:48PM +0100, Hugh Dickins wrote:
> I see you're going for locking the page around page_convert_anon,
> to guard page->mapping against truncation.  Nice thought,
> but the words "tip" and "iceberg" spring to mind.
> Truncating a sys_remap_file_pages file?  You're the first to
> begin to consider such an absurd possibility: vmtruncate_list
> still believes vm_pgoff tells it what needs to be done.
> I propose that we don't change vmtruncate_list, zap_page_range, ...
> at all for this: let it unmap inappropriate pages, even from a
> VM_LOCKED vma, that's just a price userspace pays for the
> privilege of truncating a sys_remap_file_pages file.

Hmm, aren't the file offset calculations wrong for sys_remap_file_pages()
even before objrmap?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

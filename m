Date: Sat, 19 May 2007 15:09:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] increase struct page size?!
Message-Id: <20070519150934.bdabc9b5.akpm@linux-foundation.org>
In-Reply-To: <20070519181501.GC19966@holomorphy.com>
References: <20070518040854.GA15654@wotan.suse.de>
	<Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
	<20070519012530.GB15569@wotan.suse.de>
	<20070519181501.GC19966@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007 11:15:01 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:

> Much the same holds for the atomic_t's; 32 + PAGE_SHIFT is
> 44 bits or more, about as much as is possible, and one reference per
> page per page is not even feasible. Full-length atomic_t's are just
> not necessary.

You can overflow a page's refcount by mapping it 4G times.  That requires
32GB of pagetable memory.  It's quite feasible with remap_file_pages().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

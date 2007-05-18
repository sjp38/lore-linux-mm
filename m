Date: Fri, 18 May 2007 00:19:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] increase struct page size?!
Message-Id: <20070518001905.54cafeeb.akpm@linux-foundation.org>
In-Reply-To: <20070518040854.GA15654@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007 06:08:54 +0200 Nick Piggin <npiggin@suse.de> wrote:

> Many batch operations on struct page are completely random,

But they shouldn't be: we should aim to place physically contiguous pages
into logically contiguous pagecache slots, for all the reasons we
discussed.

If/when that happens, there will be a *lot* of locality of reference
against the pageframes in a lot of important codepaths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

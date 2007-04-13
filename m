Date: Fri, 13 Apr 2007 13:13:48 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] generic rwsems
Message-ID: <20070413121348.GA28335@infradead.org>
References: <20070413102518.GD31487@wotan.suse.de> <20070413100416.GC31487@wotan.suse.de> <25428.1176464690@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25428.1176464690@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 12:44:50PM +0100, David Howells wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > I think I should put wait_lock after wait_list, so as to get a better
> > packing on most 64-bit architectures.
> 
> It makes no difference.  struct lockdep_map contains at least one pointer and
> so is going to be 8-byte aligned (assuming it's there at all).  struct
> rw_semaphore contains at least one pointer/long, so it will be padded out to
> 8-byte size.

I hope people are not going to enabled lockdep on their production systems :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

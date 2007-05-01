Date: Tue, 1 May 2007 02:04:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: cache-pipe-buf-page-address-for-non-highmem-arch.patch
Message-Id: <20070501020441.10b6a003.akpm@linux-foundation.org>
In-Reply-To: <20070501085431.GD14364@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<20070501085431.GD14364@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kenchen@google.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007 09:54:31 +0100 Christoph Hellwig <hch@infradead.org> wrote:

> >  cache-pipe-buf-page-address-for-non-highmem-arch.patch
> 
> I still don't like this one at all.  If page_address on x86_64 is too
> slow we should fix the root cause.

Fair enough, it is a bit of an ugly thing.  And I see no measurements there
on what the overall speedup was for any workload.

Ken, which memory model was in use?  sparsemem?

Andi, what are the prospects of speeding any of that up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

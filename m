Date: Tue, 20 Mar 2007 21:52:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Message-ID: <20070321045214.GE2986@holomorphy.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4600B216.3010505@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
>>  	struct vm_operations_struct * vm_ops;
>> +	const struct pagetable_operations_struct * pagetable_ops;

On Wed, Mar 21, 2007 at 03:18:30PM +1100, Nick Piggin wrote:
> Can you remind me why this isn't in vm_ops?
> Also, it is going to be hugepage-only, isn't it? So should the naming be
> changed to reflect that? And #ifdef it...

ISTR potential ppc64 users coming out of the woodwork for something I
didn't recognize the name of, but I may be confusing that with your
patch. I can implement additional users (and useful ones at that)
needing this in particular if desired.


Adam Litke wrote:
>> +struct pagetable_operations_struct {
>> +	int (*fault)(struct mm_struct *mm,

On Wed, Mar 21, 2007 at 03:18:30PM +1100, Nick Piggin wrote:
> I got dibs on fault ;)
> My callback is a sanitised one that basically abstracts the details of the
> virtual memory mapping away, so it is usable by drivers and filesystems.
> You actually want to bypass the normal fault handling because it doesn't
> know how to deal with your virtual memory mapping. Hmm, the best suggestion
> I can come up with is handle_mm_fault... unless you can think of a better
> name for me to use.

Two fault handling methods callbacks raise an eyebrow over here at least.
I was vaguely hoping for unification of the fault handling callbacks.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

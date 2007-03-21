Date: Wed, 21 Mar 2007 16:32:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Message-ID: <20070321233227.GK2986@holomorphy.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au> <1174490261.21684.13.camel@localhost.localdomain> <4601B96F.2080707@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4601B96F.2080707@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
>> We didn't want to bloat the size of the vm_ops struct for all of its
>> users.

On Thu, Mar 22, 2007 at 10:02:07AM +1100, Nick Piggin wrote:
> But vmas are surely far more numerous than vm_ops, aren't they?

It should be clarified that the pointer to the operations structure
in once-per-mmap() vmas is a bigger overhead than once-per-driver
function pointers in the vm_ops structure.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <4601B9DB.6040104@yahoo.com.au>
Date: Thu, 22 Mar 2007 10:03:55 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
 helper macros.
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au> <1174490261.21684.13.camel@localhost.localdomain> <20070321160051.GA5264@infradead.org>
In-Reply-To: <20070321160051.GA5264@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Wed, Mar 21, 2007 at 10:17:40AM -0500, Adam Litke wrote:
> 
>>>Also, it is going to be hugepage-only, isn't it? So should the naming be
>>>changed to reflect that? And #ifdef it...
>>
>>They are doing some interesting things on Cell that could take advantage
>>of this.
> 
> 
> That would be new to me.  What we need on Cell is fixing up the
> get_unmapped_area mess which Ben is working on now.
> 
> And let me once again repeat that I don't like this at all.  I'll
> rather have a few ugly ifdefs in strategic places than a big object
> oriented mess like this with just a single user.

I think I agree that we'd need more than one user for this.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

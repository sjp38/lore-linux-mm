Message-ID: <4600E062.8020001@yahoo.com.au>
Date: Wed, 21 Mar 2007 18:36:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
 helper macros.
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au> <20070321045214.GE2986@holomorphy.com> <4600BD9F.8030609@yahoo.com.au> <20070321054102.GF2986@holomorphy.com> <4600D5EB.90507@yahoo.com.au>
In-Reply-To: <4600D5EB.90507@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Yeah you could, but it looks back to front to me.
> 
> The VM tells the filesystem that the machine took a fault at virtual
> address X, then the filesystem asks the VM what pgoff that is, then
> tells the VM to install the corresponding page to vaddr X.
> 
> With my ->fault, the VM asks the filesystem to give the page that
> corresponds to vaddr X, then installs it into that vaddr.

Err, sorry, that's what the current ->nopage does. It is then still
up to the filesystem to do the vaddr to pgoff conversion.

My fault patches of course just ask the filesystem for the page at
a given pgoff.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

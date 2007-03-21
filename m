Message-ID: <4601B96F.2080707@yahoo.com.au>
Date: Thu, 22 Mar 2007 10:02:07 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
 helper macros.
References: <20070319200502.17168.17175.stgit@localhost.localdomain>	 <20070319200513.17168.52238.stgit@localhost.localdomain>	 <4600B216.3010505@yahoo.com.au> <1174490261.21684.13.camel@localhost.localdomain>
In-Reply-To: <1174490261.21684.13.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> On Wed, 2007-03-21 at 15:18 +1100, Nick Piggin wrote:
> 
>>Adam Litke wrote:

>>>diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>index 60e0e4a..7089323 100644
>>>--- a/include/linux/mm.h
>>>+++ b/include/linux/mm.h
>>>@@ -98,6 +98,7 @@ struct vm_area_struct {
>>> 
>>> 	/* Function pointers to deal with this struct. */
>>> 	struct vm_operations_struct * vm_ops;
>>>+	const struct pagetable_operations_struct * pagetable_ops;
>>> 
>>> 	/* Information about our backing store: */
>>> 	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
>>
>>Can you remind me why this isn't in vm_ops?
> 
> 
> We didn't want to bloat the size of the vm_ops struct for all of its
> users.

But vmas are surely far more numerous than vm_ops, aren't they?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <47547A79.2060206@redhat.com>
Date: Mon, 03 Dec 2007 16:51:53 -0500
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] powerpc: make 64K huge pages more reliable
References: <474CF694.8040700@us.ibm.com> <20071203020648.GF26919@localhost.localdomain>
In-Reply-To: <20071203020648.GF26919@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kniht@linux.vnet.ibm.com, linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

David Gibson wrote:
> On Tue, Nov 27, 2007 at 11:03:16PM -0600, Jon Tollefson wrote:
>> This patch adds reliability to the 64K huge page option by making use of 
>> the PMD for 64K huge pages when base pages are 4k.  So instead of a 12 
>> bit pte it would be 7 bit pmd and a 5 bit pte. The pgd and pud offsets 
>> would continue as 9 bits and 7 bits respectively.  This will allow the 
>> pgtable to fit in one base page.  This patch would have to be applied 
>> after part 1.
> 
> Hrm.. shouldn't we just ban 64K hugepages on a 64K base page size
> setup?  There's not a whole lot of point to it, after all...
> 

Actually, it sounds to me like an ideal way to benchmark the efficiency of the 
hugepage implementation and VM effects, without the TLB performance obscuring 
the results.

I agree that it's not something people will want to do very often, but the same 
can be said about quite a lot of strange things that we allow just because 
there's no fundamental reason why they cannot be.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <3E6535D9.1070804@us.ibm.com>
Date: Tue, 04 Mar 2003 15:25:13 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove __pte_offset
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com> <20030304181002.A16110@redhat.com> <629570000.1046819361@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>>ptes this time
>>
>>Isn't pte_to_pfn a better name?  index doesn't have a type of data 
>>implied, whereas pfn does.  We have to make these distinctions clearer 
>>as work like William's PAGE_SIZE is being done.
> 
> For pte_index? Surely they're completely separate things?
> pte_index returns a virtual address offset into the pte, and
> pte_to_pfn returns a physical address?

Yeah, Martin's right.  I jumped the gun with that second patch

#define pte_index(address) \
                (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))

We _are_ talking about the address and conversion to the index into the
pte page here, not the contents of the pte and thus the pfn.

Please stop confusing me, the voices in my head are bad enough :)
-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

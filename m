Message-ID: <3E653D69.8000007@us.ibm.com>
Date: Tue, 04 Mar 2003 15:57:29 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove __pte_offset
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com> <20030304181002.A16110@redhat.com> <629570000.1046819361@flay> <20030304182652.B16110@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Tue, Mar 04, 2003 at 03:09:21PM -0800, Martin J. Bligh wrote:
> 
>>For pte_index? Surely they're completely separate things?
>>pte_index returns a virtual address offset into the pte, and
>>pte_to_pfn returns a physical address?
> 
> Sorry, I was only thinking about the type of the index initially, not 
> the type of the data being passed into the macro.  Yes, the macro does 
> take an address, so it should be more like addr_to_pfn_index or somesuch.  
> I still think pte_index isn't clear, though.

While we're on the subject, does anyone else find the p*_offset
functions confusing?

Maybe something like this?
vaddr_to_pgd_entry(mm, address)
virt_to_pgd_entry(mm, address)

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

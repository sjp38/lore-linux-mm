Date: Tue, 04 Mar 2003 15:29:10 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] remove __pte_offset
Message-ID: <631570000.1046820550@flay>
In-Reply-To: <20030304182652.B16110@redhat.com>
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com> <20030304181002.A16110@redhat.com> <629570000.1046819361@flay> <20030304182652.B16110@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Sorry, I was only thinking about the type of the index initially, not 
> the type of the data being passed into the macro.  Yes, the macro does 
> take an address, so it should be more like addr_to_pfn_index or somesuch.  
> I still think pte_index isn't clear, though.

It's not a pfn index though - pfns are physical, this is virtual still.

It's the index into the pte page ... vaddr_to_pte_page_index I guess,
but pte_index seems easier ;-)

> akpm
> pfn = pageframe number.

Right, yes ... but that's still really just a physical address (>> PAGE_SHIFT).
I was trying to emphasize phys vs virt. But I was being needlessly obtuse ;-) 

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

Date: Tue, 4 Mar 2003 18:26:52 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] remove __pte_offset
Message-ID: <20030304182652.B16110@redhat.com>
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com> <20030304181002.A16110@redhat.com> <629570000.1046819361@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <629570000.1046819361@flay>; from mbligh@aracnet.com on Tue, Mar 04, 2003 at 03:09:21PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 04, 2003 at 03:09:21PM -0800, Martin J. Bligh wrote:
> For pte_index? Surely they're completely separate things?
> pte_index returns a virtual address offset into the pte, and
> pte_to_pfn returns a physical address?

Sorry, I was only thinking about the type of the index initially, not 
the type of the data being passed into the macro.  Yes, the macro does 
take an address, so it should be more like addr_to_pfn_index or somesuch.  
I still think pte_index isn't clear, though.

		-ben
-- 
Junk email?  <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

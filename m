Date: Tue, 04 Mar 2003 15:09:21 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] remove __pte_offset
Message-ID: <629570000.1046819361@flay>
In-Reply-To: <20030304181002.A16110@redhat.com>
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com> <20030304181002.A16110@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> ptes this time
> 
> Isn't pte_to_pfn a better name?  index doesn't have a type of data 
> implied, whereas pfn does.  We have to make these distinctions clearer 
> as work like William's PAGE_SIZE is being done.

For pte_index? Surely they're completely separate things?
pte_index returns a virtual address offset into the pte, and
pte_to_pfn returns a physical address?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA21045
	for <linux-mm@kvack.org>; Tue, 4 Mar 2003 15:26:51 -0800 (PST)
Date: Tue, 4 Mar 2003 15:22:57 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] remove __pte_offset
Message-Id: <20030304152257.7b6d6e3f.akpm@digeo.com>
In-Reply-To: <629570000.1046819361@flay>
References: <3E653012.5040503@us.ibm.com>
	<3E6530B3.2000906@us.ibm.com>
	<20030304181002.A16110@redhat.com>
	<629570000.1046819361@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: bcrl@redhat.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> >> ptes this time
> > 
> > Isn't pte_to_pfn a better name?  index doesn't have a type of data 
> > implied, whereas pfn does.  We have to make these distinctions clearer 
> > as work like William's PAGE_SIZE is being done.
> 
> For pte_index? Surely they're completely separate things?

Yes, they are.  A pfn is a fairly distinct thing with "meaning".

> pte_index returns a virtual address offset into the pte, and

pte index into the pagetable page <thwap>

> pte_to_pfn returns a physical address?

pageframe number.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

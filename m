Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6SHKUkQ440468
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 13:20:32 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6SHKWb4118526
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 11:20:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6SHKTCI012000
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 11:20:29 -0600
Subject: Re: [patch] mm: Ensure proper alignment for node_remap_start_pfn
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050728013134.GB23923@localhost.localdomain>
References: <20050728004241.GA16073@localhost.localdomain>
	 <20050727181724.36bd28ed.akpm@osdl.org>
	 <20050728013134.GB23923@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 28 Jul 2005 10:20:26 -0700
Message-Id: <1122571226.23386.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-07-27 at 18:31 -0700, Ravikiran G Thirumalai wrote:
> On Wed, Jul 27, 2005 at 06:17:24PM -0700, Andrew Morton wrote:
> > Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> > >
> > > While reserving KVA for lmem_maps of node, we have to make sure that
> > > node_remap_start_pfn[] is aligned to a proper pmd boundary.
> > > (node_remap_start_pfn[] gets its value from node_end_pfn[])
> > > 
> > 
> > What are the effects of not having this patch applied?  Does someone's
> > computer crash, or what?
> 
> Yes, it does cause a crash.

I don't know of any NUMA x86 sub-arches that have nodes which are
aligned on any less than 2MB.  Is this an architecture that's supported
in the tree, today?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

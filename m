Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1OM325j840514
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 17:03:04 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1OM2wov118560
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 15:03:02 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1OM2vog004852
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 15:02:58 -0700
Subject: Re: [PATCH 5/5] SRAT cleanup: make calculations and indenting
	level more sane
From: keith <kmannth@us.ibm.com>
In-Reply-To: <200502241249.54796.jamesclv@us.ibm.com>
References: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com>
	 <1109273434.9817.1950.camel@knk> <1109274881.7244.87.camel@localhost>
	 <200502241249.54796.jamesclv@us.ibm.com>
Content-Type: text/plain
Message-Id: <1109282578.9817.1993.camel@knk>
Mime-Version: 1.0
Date: Thu, 24 Feb 2005 14:02:58 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jamesclv@us.ibm.com
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, matt dobson <colpatch@us.ibm.com>, Mike Kravetz <kravetz@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Anton Blanchard <anton@samba.org>, Yasunori Goto <ygoto@us.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-02-24 at 12:49, James Cleverdon wrote:
> No, I don't think we could rely on that.  Our BIOS did ascending 
> addresses, but I don't recall that being spelled out in the ACPI spec.
> 
> Of course, there's a new ACPI spec out.  Maybe it makes it a 
> requirement.  I'd take a look, but I can't afford the loss of sanity 
> caused by gazing on the dread visage of ACPI 3.0.   ;^)


The SRAT exists outside of the ACPI spec.  It is something made up by
folks in Kirkland.  I just reread the SRAT spec and I don't seen any
mention of requirements for linear order.  Still yet we have yet to find
a box/bios version that breaks this assumption. All I know of is the IBM
summit boxes but maybe there is something else.  

Maybe AMD x86_64 booting into 32 bit have SRATs as well?

Anyways maybe we could add some check to catch new hardware with less
friendly SRAT tables. 

after the  node_has_online_mem(nid) check 

if (node_start_pfn[nid] > node_memory_chunk[j].start_pfn) {
	printk (KERN_WARN "You need to rework the srat.c code\n");
	continue;
}

Keith 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

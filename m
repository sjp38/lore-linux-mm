Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1LKddMN322274
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 15:39:39 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1LKdc40116016
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 13:39:38 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1LKdclI028321
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 13:39:38 -0700
Subject: Re: [RFC] [Patch] For booting a i386 numa system with no memory in
	a node
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1109017040.9817.1638.camel@knk>
References: <1106881119.2040.122.camel@cog.beaverton.ibm.com>
	 <1106882150.2040.126.camel@cog.beaverton.ibm.com>
	 <1106937253.27125.6.camel@knk>  <1106938993.14330.65.camel@localhost>
	 <1106941547.27125.25.camel@knk>  <1106942832.17936.3.camel@arrakis>
	 <1108611260.9817.1227.camel@knk>  <1108654782.19395.9.camel@localhost>
	 <1108664637.9817.1259.camel@knk>  <1108666091.19395.29.camel@localhost>
	 <1108671423.9817.1266.camel@knk>  <421510E9.3000901@us.ibm.com>
	 <1108677113.32193.8.camel@localhost> <42152690.4030508@us.ibm.com>
	 <9230000.1108666127@flay>  <1108686742.6482.51.camel@localhost>
	 <1109017040.9817.1638.camel@knk>
Content-Type: text/plain
Date: Mon, 21 Feb 2005 12:39:21 -0800
Message-Id: <1109018361.21720.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>, matt dobson <colpatch@us.ibm.com>, John Stultz <johnstul@us.ibm.com>, Andy Whitcroft <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-02-21 at 12:17 -0800, keith wrote:
>   Attach is a patch that allows a i386 numa based system to boot without
> memory in a node.  It deals with the assumption that all nodes have
> memory.  

The diff is backwards :)

> -                       if (node_memory_chunk[j].start_pfn >= max_pfn)
> {
> -                               printk ("Ignoring chunk of memory
> reported in the SRAT (could be hot-add zone?)\n");
> -                               continue;
> -                       }

Could you print out the memory ranges, or sizes here?  Also, please add
a KERN_* level to it.  We might not want this unless the user has booted
with "debug".

> +               if (node_has_online_mem(nid)){
> +                       if (start > low) {

Instead of indenting another level, can you just put a continue in the
loop?  I think it makes it much easier to read.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

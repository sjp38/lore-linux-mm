Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DLlWcL003190
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 17:47:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DLlWGv158948
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 15:47:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DLlWp5032753
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 15:47:32 -0600
Subject: Re: [PATCH] Get rid of zone_table
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
	 <1158180795.9141.158.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 14:47:27 -0700
Message-Id: <1158184047.9141.164.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Now that I think about it, we should have room to encode that thing
inside of the section number on 32-bit platforms.

We have 32-bits of space, and we need to encode a number that is a
maximum of 4 bits in size.  That leaves 28 bits minus the one that we
use for the section present bit.  Our minimum section size on x86 is
something like 64 or 128MB.  Let's say 64MB.  So, on a 64GB system, we
only need 1k sections, and 10 bits.

So, the node number would almost certainly fit in the existing
mem_section.  We'd just need to set it and mask it out.  

Andy, what do you think?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

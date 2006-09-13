Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DLx0vS029561
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 17:59:00 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DLx02e294926
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 15:59:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DLx0b6031958
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 15:59:00 -0600
Subject: Re: [PATCH] Get rid of zone_table
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0609131452330.19506@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
	 <1158180795.9141.158.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
	 <1158184047.9141.164.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0609131452330.19506@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 14:58:55 -0700
Message-Id: <1158184735.9141.167.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-13 at 14:54 -0700, Christoph Lameter wrote:
> On Wed, 13 Sep 2006, Dave Hansen wrote:
> > Now that I think about it, we should have room to encode that thing
> > inside of the section number on 32-bit platforms.
> 
> We already have 1k nodes on IA64 and you can expect 16k in the 
> near future. I think you need at least 16 bit.
> 
> Sorry I am a bit new to sparsemem but it seems that the mem sections are 
> arrays of pointers. You would like to store the node number in the lower 
> unused bits?

I thought this patch was only for 32-bit NUMA platforms that have run
out of bits in page->flags to encode the data.  Does it apply to ia64 as
well somehow?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

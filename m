Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1OJt4Na003296
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:55:04 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1OJt4St251614
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:55:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1OJsrBk018375
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:54:53 -0500
Subject: Re: [PATCH 5/5] SRAT cleanup: make calculations and indenting
	level more sane
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1109273434.9817.1950.camel@knk>
References: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com>
	 <1109273434.9817.1950.camel@knk>
Content-Type: text/plain
Date: Thu, 24 Feb 2005 11:54:41 -0800
Message-Id: <1109274881.7244.87.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, matt dobson <colpatch@us.ibm.com>, Mike Kravetz <kravetz@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Anton Blanchard <anton@samba.org>, Yasunori Goto <ygoto@us.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>, James Cleverdon <jamesclv@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-02-24 at 11:30 -0800, keith wrote:
> Why not take it one step further??  Something like the attached patch.
> There is no reason to loop over the nodes as the srat entries contain
> node info and we can use the the new node_has_online_mem. 

You took away my function :)

Seriously, though, that does look better.  Although, I still wouldn't
mind seeing it kept broken out in another function like my patch.

> This booted ok on my hot-add enabled 8-way. 
>  I am not %100 sure it is ok to make the assumption that the memory is
> always reported linearly but that is the assumption of the previous code
> so it must be for all know examples. 

Hey James, didn't we decide at some point that the SRAT could only have
chunks with ascending addresses?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

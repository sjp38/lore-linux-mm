Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DKsBTV008666
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 16:54:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DKsBou560538
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 16:54:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DKsA97001134
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 16:54:10 -0400
Subject: Re: 2.6.23-rc4-mm1 memory controller BUG_ON()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <46E99BDE.9000602@linux.vnet.ibm.com>
References: <1189712083.17236.1626.camel@localhost>
	 <46E99BDE.9000602@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 13:54:09 -0700
Message-Id: <1189716849.17236.1712.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 01:51 +0530, Balbir Singh wrote:
> Dave Hansen wrote:
> > Looks like somebody is holding a lock while trying to do a
> > mem_container_charge(), and the mem_container_charge() call is doing
> an
> > allocation.  Naughty.
> > 
> > I'm digging into it a bit more, but thought I'd report it, first.
> > 
> 
> Hi, Dave,
> 
> Thanks for reporting this. I sent out a patch to fix this problem
> (suggested by Nick Piggin). The patch is available at
> 
> http://lkml.org/lkml/2007/9/12/113
> 
> Could you try the patch and check if the problem goes away? 

Balbir and I had a chat about this on IRC.  Those patches don't seem to
fix it.  But, I'm getting Balbir hooked up with the kvm instance that I
ran this in along with my .config.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

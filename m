Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2AKHT5j738608
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 15:17:29 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2AKHT5C170316
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 13:17:29 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2AKHSW9023624
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 13:17:29 -0700
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy (Version 9)
	+ prezeroing (Version 4)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050310121124.488cb7c5.pj@engr.sgi.com>
References: <20050307193938.0935EE594@skynet.csn.ul.ie>
	 <1110239966.6446.66.camel@localhost>
	 <Pine.LNX.4.58.0503101421260.2105@skynet>
	 <20050310092201.37bae9ba.pj@engr.sgi.com>
	 <1110478613.16432.36.camel@localhost>
	 <20050310121124.488cb7c5.pj@engr.sgi.com>
Content-Type: text/plain
Date: Thu, 10 Mar 2005 12:17:15 -0800
Message-Id: <1110485835.24355.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@engr.sgi.com>
Cc: mel@csn.ul.ie, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-03-10 at 12:11 -0800, Paul Jackson wrote:
> Dave wrote:
> > Perhaps default policies inherited from a cpuset, but overridden by
> > other APIs would be a good compromise.
> 
> Perhaps.  The madvise() and numa calls (mbind, set_mempolicy) only
> affect the current task, as is usually appropriate for calls that allow
> specification of specific address ranges (strangers shouldn't be messing
> in my address space).  Some external means to set default policy for
> whole tasks seems to be needed, as well, which could well be via the
> cpuset.

Shouldn't a particular task know what the policy should be when it is
launched?  If the policy is only per-task and known at task exec time,
I'd imagine that a simple exec wrapper setting a flag would be much more
effective than even defining the policy in a cpuset.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3EHXUbE006300
	for <linux-mm@kvack.org>; Fri, 14 Apr 2006 13:33:30 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3EHXUoe255920
	for <linux-mm@kvack.org>; Fri, 14 Apr 2006 13:33:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3EHXTSN004984
	for <linux-mm@kvack.org>; Fri, 14 Apr 2006 13:33:30 -0400
Subject: RE: [RFD hugetlbfs] strict accounting and wasteful reservations
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <4t153d$lv444@azsmga001.ch.intel.com>
References: <4t153d$lv444@azsmga001.ch.intel.com>
Content-Type: text/plain
Date: Fri, 14 Apr 2006 12:33:28 -0500
Message-Id: <1145036008.10795.122.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, akpm@osdl.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-04-13 at 18:55 -0700, Chen, Kenneth W wrote:
> Arbitrary offset isn't that bad, here is the patch that I forward port to
> 2.6.17-rc1.  It is just 35 lines more.  Another thing I can do is to put
> the variable region tracking code into a library function, maybe that will
> help to move it along?  I'm with Adam, I don't like to see hugetlbfs have
> yet another uncommon behavior.

Thanks Ken.  The patch passes the libhugetlbfs test suite and also works
as advertised for sparse mappings.  I don't recall, is this the version
you and David were converging on before Dave's patch was merged?  I seem
to remember a few iterations of this patch centered locking discussions,
etc.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

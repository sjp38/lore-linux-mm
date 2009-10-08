Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2B0516B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:22:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2694082C4F9
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:26:50 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LLqiz768hUM3 for <linux-mm@kvack.org>;
	Thu,  8 Oct 2009 16:26:44 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 11CC082C2EC
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:26:44 -0400 (EDT)
Date: Thu, 8 Oct 2009 16:16:23 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 6/12] hugetlb:  add generic definition of NUMA_NO_NODE
In-Reply-To: <20091008162533.23192.71981.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0910081616040.8030@gentwo.org>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162533.23192.71981.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>


Would it not be good to convert all the uses of -1 to NUMA_NO_NODE as
well?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

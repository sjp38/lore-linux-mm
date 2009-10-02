Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E972B60021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 19:28:15 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 65FBD82C826
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 19:32:05 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zrmXoEo7EuiO for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 19:32:00 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BBA3F82C4BA
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 19:32:00 -0400 (EDT)
Date: Fri, 2 Oct 2009 19:23:33 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.1.10.0910021922460.8056@gentwo.org>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, David Rientjes wrote:

>  [ FYI: I'm not sure clameter@sgi.com still works, you may want to try
>    cl@linux-foundation.org. ]

clameter@sgi.com it has not been working for one and a half years.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

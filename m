Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0236860021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:53:30 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 86A2582C79D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:57:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aqSpyELzbOgW for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 18:57:14 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CAD1F82C7EF
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:57:09 -0400 (EDT)
Date: Fri, 2 Oct 2009 18:48:28 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] nodemask: make NODEMASK_ALLOC more general
In-Reply-To: <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.1.10.0910021839470.11884@gentwo.org>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, David Rientjes wrote:

> NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
> It's perfectly reasonable to use this macro to allocate a nodemask_t,
> which is anonymous, either dynamically or on the stack depending on
> NODES_SHIFT.

There is currently only one user of NODEMASK_ALLOC which is
NODEMASK_SCRATCH.

Can we generalize the functionality here? The macro is basically choosing
between a slab allocation or a stack allocation depending on the
configured system size.

NUMA_COND__ALLOC(<type>, <min numa nodes for not using stack>,
<variablename>)

or so?

Its likely that one way want to allocate other structures on the stack
that may get too big if large systems need to be supported.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

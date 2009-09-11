Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E84B86B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 09:54:26 -0400 (EDT)
Subject: Re: [PATCH 1/3] hugetlb:  use only nodes with memory for huge pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090910163319.7fcfe815.akpm@linux-foundation.org>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	 <20090909163211.12963.40411.sendpatchset@localhost.localdomain>
	 <20090910163319.7fcfe815.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 11 Sep 2009 09:54:29 -0400
Message-Id: <1252677269.4392.285.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-10 at 16:33 -0700, Andrew Morton wrote:
> I ducked these three.  It's already a bit late for the first six, and
> that first six looked a bit half-baked to me.

That's appropriate.  These 3 were new in V6, and I have some cleanup,
better comments, ... queued up.  But the others:  "half-baked" ???  More
like 3/4, methinks. :)

Anyway, I'm glad to see you've added them to mmotm.  I've been testing
each version of the series on x86_64 and, occassionally, ia64, with the
libhugetlbfs regression tests and ad hoc testing of the mempolicy based
constraint and the per node attributes.  I believe that Mel has been
testing on ppc.  But, they definitely can benefit from more exposure.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

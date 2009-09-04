Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E2C916B0085
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 11:23:00 -0400 (EDT)
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
 mempolicy based management.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090903134210.5a27611d.randy.dunlap@oracle.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
	 <20090828160351.11080.21379.sendpatchset@localhost.localdomain>
	 <20090903134210.5a27611d.randy.dunlap@oracle.com>
Content-Type: text/plain
Date: Fri, 04 Sep 2009 11:23:03 -0400
Message-Id: <1252077783.4389.54.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-03 at 13:42 -0700, Randy Dunlap wrote:
> On Fri, 28 Aug 2009 12:03:51 -0400 Lee Schermerhorn wrote:
> 
> (Thanks for cc:, David.)

Randy:  thanks for the review.  I'll add you to the cc list for
reposting of the series.  I'll make all of the changes you suggest,
except those that you seemed to concede might not be required:

1) surplus vs overcommitted.  The currently exported user space
interface uses both "overcommit" for specifying the limit and "surplus"
for displaying the number of overcommitted pages in use.  I agree that
it's somewhat of a misuse of "surplus" as the count actually indicates
"deficit spending" of huge page resources.

2)  the s/cpu/CPU/.  As you say, that cat is on the run.

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

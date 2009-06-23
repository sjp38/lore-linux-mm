Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C85416B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:24:32 -0400 (EDT)
Message-ID: <4A41481D.1060607@redhat.com>
Date: Tue, 23 Jun 2009 17:24:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>	 <1245732411.18339.6.camel@alok-dev1>	 <20090623135017.220D.A69D9226@jp.fujitsu.com>	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com> <1245736441.18339.21.camel@alok-dev1>
In-Reply-To: <1245736441.18339.21.camel@alok-dev1>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Alok Kataria wrote:

> Both, while working on an module I noticed that there is no way direct
> way to get any information regarding the total number of unrecliamable
> (unevictable) pages in the system. While reading through the kernel
> sources i came across this unevictalbe LRU framework and thought that
> this should actually work towards providing  total unevictalbe pages in
> the system irrespective of where they reside.

The unevictable count tells you how many _userspace_
pages are not evictable.

There are countless accounted and unaccounted kernel
allocations that show up (or not) in other fields in
/proc/meminfo.

I can see something reasonable on both sides of this
particular debate.  However, even with this patch the
"unevictable" statistic does not reclaim the total
number of pages that are unevictable pages from a
zone, so I am not sure how it helps you achieve your
goal.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

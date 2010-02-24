Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9BABE6B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 16:29:05 -0500 (EST)
Date: Wed, 24 Feb 2010 13:28:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 36/36] khugepaged
Message-Id: <20100224132818.fb53d10d.akpm@linux-foundation.org>
In-Reply-To: <4B859900.6060504@redhat.com>
References: <20100221141009.581909647@redhat.com>
	<20100221141758.658303189@redhat.com>
	<20100224121111.232602ba.akpm@linux-foundation.org>
	<4B858BFC.8020801@redhat.com>
	<20100224125253.2edb4571.akpm@linux-foundation.org>
	<4B8592BB.1040007@redhat.com>
	<20100224131220.396216af.akpm@linux-foundation.org>
	<4B859900.6060504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010 16:24:16 -0500 Rik van Riel <riel@redhat.com> wrote:

> The hugepage patchset as it stands tries to allocate huge
> pages synchronously, but will fall back to normal 4kB pages
> if they are not.
> 
> Similarly, khugepaged only compacts anonymous memory into
> hugepages if/when hugepages become available.
> 
> Trying to always allocate hugepages synchronously would
> mean potentially having to defragment memory synchronously,
> before we can allocate memory for a page fault.
> 
> While I have no numbers, I have the strong suspicion that
> the performance impact of potentially defragmenting 2MB
> of memory before each page fault could lead to more
> performance inconsistency than allocating small pages at
> first and having them collapsed into large pages later...
> 
> The amount of work involved in making a 2MB page available
> could be fairly big, which is why I suspect we will be
> better off doing it asynchronously - preferably on otherwise
> idle CPU core.

Sounds right.  How much CPU consumption are we seeing from khugepaged?

The above-quoted text would make a good addition to the (skimpy)
changelog!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

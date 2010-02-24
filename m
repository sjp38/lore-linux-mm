Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB35A6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:12:24 -0500 (EST)
Date: Wed, 24 Feb 2010 12:11:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 36/36] khugepaged
Message-Id: <20100224121111.232602ba.akpm@linux-foundation.org>
In-Reply-To: <20100221141758.658303189@redhat.com>
References: <20100221141009.581909647@redhat.com>
	<20100221141758.658303189@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Feb 2010 15:10:45 +0100 aarcange@redhat.com wrote:

> Add khugepaged to relocate fragmented pages into hugepages if new hugepages
> become available. (this is indipendent of the defrag logic that will have to
> make new hugepages available)

What does this mean?  What are the user-visible effects if (when) this
kernel thread fails to keep up?

Generally it seems like a bad idea to do this sort of thing
asynchronously.  Because it reduces repeatability across runs and
across machines - system behaviour becomes more dependent on the size
of the machine and the amount of activity in unrelated jobs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

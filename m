Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E720C6001DA
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 13:00:41 -0500 (EST)
Date: Mon, 22 Feb 2010 19:00:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 25/36] _GFP_NO_KSWAPD
Message-ID: <20100222180009.GM11504@random.random>
References: <20100221141009.581909647@redhat.com>
 <20100221141756.772875923@redhat.com>
 <4B82C487.9020407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B82C487.9020407@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 22, 2010 at 12:53:11PM -0500, Rik van Riel wrote:
> Once Mel's defragmentation code is in, we can kick off
> that code instead when a hugepage allocation fails.

That will be cool yes!! Then maybe we can turn on defrag by
default... (maybe because it'd still slowdown the allocation time)

I think at least for khugepaged invoking memory compaction code by
default is going to be good idea. And then I wonder if it makes sense
to allow the user to disable defrag in khugepaged, if yes then it'd
require a new sysfs file in the khugepaged directory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

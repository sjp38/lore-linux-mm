Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DA4936B01E3
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:35:43 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o370ZfKw016022
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 7 Apr 2010 09:35:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AF1145DE53
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:35:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 172B545DE52
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:35:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD9421DB8012
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:35:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 088AAE38003
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:35:37 +0900 (JST)
Date: Wed, 7 Apr 2010 09:31:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/14] Add /sys trigger for per-node memory compaction
Message-Id: <20100407093148.d5d1c42f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100406170559.52093bd5.akpm@linux-foundation.org>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-11-git-send-email-mel@csn.ul.ie>
	<20100406170559.52093bd5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 2010 17:05:59 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri,  2 Apr 2010 17:02:44 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a per-node sysfs file called compact. When the file is
> > written to, each zone in that node is compacted. The intention that this
> > would be used by something like a job scheduler in a batch system before
> > a job starts so that the job can allocate the maximum number of
> > hugepages without significant start-up cost.
> 
> Would it make more sense if this was a per-memcg thing rather than a
> per-node thing?

memcg doesn't have any relationship with placement of memory (now).
It's just controls the amount of memory.
So, memcg has no relationship with compaction.

A cgroup which controls placement of memory is cpuset.
One idea is per cpuset. But per-node seems ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

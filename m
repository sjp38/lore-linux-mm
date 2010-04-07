Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BAEE86B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 11:42:28 -0400 (EDT)
Date: Wed, 7 Apr 2010 16:42:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/14] Add /sys trigger for per-node memory compaction
Message-ID: <20100407154206.GS17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-11-git-send-email-mel@csn.ul.ie> <20100406170559.52093bd5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170559.52093bd5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:59PM -0700, Andrew Morton wrote:
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
> 

Kamezawa Hiroyuki covered this perfectly. memcg doesn't care and while
cpuset might, there are a lot more people working with nodes than there
are with cpuset.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

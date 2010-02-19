Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BFBBC6B008A
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 10:28:54 -0500 (EST)
Date: Fri, 19 Feb 2010 15:28:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/12] Add /sys trigger for per-node memory compaction
Message-ID: <20100219152830.GB1445@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-11-git-send-email-mel@csn.ul.ie> <20100219145358.GB24790@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100219145358.GB24790@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 06:53:59AM -0800, Greg KH wrote:
> On Thu, Feb 18, 2010 at 06:02:40PM +0000, Mel Gorman wrote:
> > This patch adds a per-node sysfs file called compact. When the file is
> > written to, each zone in that node is compacted. The intention that this
> > would be used by something like a job scheduler in a batch system before
> > a job starts so that the job can allocate the maximum number of
> > hugepages without significant start-up cost.
> 
> As you are adding sysfs files, can you please also add documentation for
> the file in Documentation/ABI/ ?
> 

I looked at this before and hit a wall and then forgot about it. I couldn't
find *where* I should document it at the time. There isn't a sysfs-devices-node
file to add to and much (all?) of what is in that branch appears undocumented.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

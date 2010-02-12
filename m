Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA3826B0078
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 13:39:11 -0500 (EST)
Date: Fri, 12 Feb 2010 18:38:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/12] Add /proc trigger for memory compaction
Message-ID: <20100212183854.GB23822@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-7-git-send-email-mel@csn.ul.ie> <7691.1265999680@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7691.1265999680@localhost>
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 01:34:40PM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 12 Feb 2010 12:00:53 GMT, Mel Gorman said:
> > This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> > value is written to the file, all zones are compacted. The expected user
> > of such a trigger is a job scheduler that prepares the system before the
> > target application runs.
> 
> Argh. A global trigger in /proc, and a per-node trigger in /sys too.  Can we
> get by with just one or the other?  Should the /proc one live in /sys too?
> 

The sysfs trigger is only visible on NUMA. The proc one is easier to use
when the requirement is "compact all memory". There doesn't appear to be a
suitable place in sysfs for the proc trigger as it's already the case that
all proc tunables are not reflected in sysfs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

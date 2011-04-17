Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A089A900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 05:30:54 -0400 (EDT)
Date: Sun, 17 Apr 2011 17:30:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110417093048.GA4027@localhost>
References: <20110416132546.765212221@intel.com>
 <4DAA976A.3080007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DAA976A.3080007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Apr 17, 2011 at 03:31:54PM +0800, Marco Stornelli wrote:
> Il 16/04/2011 15:25, Wu Fengguang ha scritto:
> > Andrew,
> >
> > This revision undergoes a number of simplifications, cleanups and fixes.
> > Independent patches are separated out. The core patches (07, 08) now have
> > easier to understand changelog. Detailed rationals can be found in patch 08.
> >
> > In response to the complexity complaints, an introduction document is
> > written explaining the rationals, algorithm and visual case studies:
> >
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
> 
> It'd be great if you wrote a summary in the kernel documentation.

Perhaps not in this stage. That will only frighten people away I'm
afraid. The main concerns now are "why the complexities?". People at
this time perhaps won't bother looking into any lengthy documents at
all.

The slides with both description text and graphs should be much easier
for the readers to establish good feelings and understandings, as well
as trust. Seeing is believing, when you see 80ms vs. 30s pause times
in the bumpy NFS workload (pages 29, 30), fast rampup when suddenly
starting 10 or 100 dd tasks (pages 38, 32), and 5ms pause time in
stable workload (page 20), don't you feel the graphs much more
striking than boring texts? :)

That said, the changelog in patches 07 and 08 do offer some text based
introductions, if you are interested in reading more.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

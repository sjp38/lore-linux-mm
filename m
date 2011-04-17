Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6AF12900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 19:31:56 -0400 (EDT)
Date: Mon, 18 Apr 2011 07:31:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110417233147.GA5176@localhost>
References: <20110416132546.765212221@intel.com>
 <4DAA976A.3080007@gmail.com>
 <20110417093048.GA4027@localhost>
 <4DAB26F6.40407@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DAB26F6.40407@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 18, 2011 at 01:44:22AM +0800, Marco Stornelli wrote:
> Il 17/04/2011 11:30, Wu Fengguang ha scritto:
> > On Sun, Apr 17, 2011 at 03:31:54PM +0800, Marco Stornelli wrote:
> >> Il 16/04/2011 15:25, Wu Fengguang ha scritto:
> >>> Andrew,
> >>>
> >>> This revision undergoes a number of simplifications, cleanups and fixes.
> >>> Independent patches are separated out. The core patches (07, 08) now have
> >>> easier to understand changelog. Detailed rationals can be found in patch 08.
> >>>
> >>> In response to the complexity complaints, an introduction document is
> >>> written explaining the rationals, algorithm and visual case studies:
> >>>
> >>> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
> >>
> >> It'd be great if you wrote a summary in the kernel documentation.
> >
> > Perhaps not in this stage. That will only frighten people away I'm
> > afraid. The main concerns now are "why the complexities?". People at
> > this time perhaps won't bother looking into any lengthy documents at
> > all.
> >
> 
> For the moment ok if you think we are in a not-ready-for-mainline yet. 
> But for the final version the documentation would be welcome, maybe with 
> the pdf as reference. The documentation is always the last thing but 
> it's important! :)

No problem. I hope it still get the chance to get upstreamed :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

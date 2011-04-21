Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BBF8D8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:47:41 -0400 (EDT)
Date: Thu, 21 Apr 2011 09:47:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421014716.GA12191@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420073822.GA30672@localhost>
 <20110421010132.GE1814@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421010132.GE1814@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 09:01:32AM +0800, Dave Chinner wrote:
> On Wed, Apr 20, 2011 at 03:38:22PM +0800, Wu Fengguang wrote:
> > > make. Please test against a vanilla kernel if that is what you are
> > > aiming these patches for. If you aren't aiming for a vanilla kernel,
> > > please say so in the patch series header...
> > 
> > Here are the test results for vanilla kernel. It's again shows better
> > numbers for dd, tar and overall run time.
> > 
> >              2.6.39-rc3   2.6.39-rc3-dyn-expire+
> > ------------------------------------------------
> > all elapsed     256.043      252.367
> > stddev           24.381       12.530
> > 
> > tar elapsed      30.097       28.808
> > dd  elapsed      13.214       11.782
> 
> The big reduction in run-to-run variance is very convincing - moreso
> than the reduction in runtime - That's kind of what I had hoped
> would occur once I understood the implications of the change. Thanks
> for running the test to close the loop. :)

And you can see how the user perceivable variations in elapsed time
are reduced by the patchsets:

vanilla 
             user       system     %cpu       elapsed
stddev       0.000      0.037      0.539      0.805     dd,  xfs
stddev       0.117      0.102      5.974      3.498     tar, xfs

moving-target
stddev       0.000      0.102      1.025      0.803     dd,  xfs
stddev       0.131      0.136      4.415      2.136     tar, xfs

IO-less + moving-target 
stddev       0.000      0.022      0.000      0.283     dd,  xfs
stddev       0.000      0.031      0.000      0.151     dd,  ext4
stddev       0.111      0.218      2.040      0.532     tar, xfs
stddev       0.129      0.119      1.020      0.215     tar, ext4

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

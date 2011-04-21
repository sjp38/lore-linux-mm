Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 022EB8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:01:39 -0400 (EDT)
Date: Thu, 21 Apr 2011 11:01:32 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421010132.GE1814@dastard>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420073822.GA30672@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420073822.GA30672@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Apr 20, 2011 at 03:38:22PM +0800, Wu Fengguang wrote:
> > make. Please test against a vanilla kernel if that is what you are
> > aiming these patches for. If you aren't aiming for a vanilla kernel,
> > please say so in the patch series header...
> 
> Here are the test results for vanilla kernel. It's again shows better
> numbers for dd, tar and overall run time.
> 
>              2.6.39-rc3   2.6.39-rc3-dyn-expire+
> ------------------------------------------------
> all elapsed     256.043      252.367
> stddev           24.381       12.530
> 
> tar elapsed      30.097       28.808
> dd  elapsed      13.214       11.782

The big reduction in run-to-run variance is very convincing - moreso
than the reduction in runtime - That's kind of what I had hoped
would occur once I understood the implications of the change. Thanks
for running the test to close the loop. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

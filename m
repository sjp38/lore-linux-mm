Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 342286B02EE
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 14:11:42 -0400 (EDT)
Date: Wed, 11 Aug 2010 02:06:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
Message-ID: <20100810180625.GA4887@localhost>
References: <20100805163401.e9754032.akpm@linux-foundation.org>
 <20100806124452.GC4717@localhost>
 <20100809235652.7113.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100809235652.7113.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 10, 2010 at 11:12:06AM +0800, KOSAKI Motohiro wrote:
> > Subject: writeback: explicit low bound for vm.dirty_ratio
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > Date: Thu Jul 15 10:28:57 CST 2010
> > 
> > Force a user visible low bound of 5% for the vm.dirty_ratio interface.
> > 
> > This is an interface change. When doing
> > 
> > 	echo N > /proc/sys/vm/dirty_ratio
> > 
> > where N < 5, the old behavior is pretend to accept the value, while
> > the new behavior is to reject it explicitly with -EINVAL.  This will
> > possibly break user space if they checks the return value.
> 
> Umm.. I dislike this change. Is there any good reason to refuse explicit 
> admin's will? Why 1-4% is so bad? Internal clipping can be changed later
> but explicit error behavior is hard to change later.
> 
> personally I prefer to
>  - accept all value, or
>  - clipping value in dirty_ratio_handler 
> 
> Both don't have explicit ABI change.

Good point. Sorry for being ignorance. Neil is right that there is no
reason to impose some low bound. So the first option looks good.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

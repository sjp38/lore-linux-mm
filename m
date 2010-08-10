Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 688796B02EF
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 14:12:24 -0400 (EDT)
Date: Wed, 11 Aug 2010 02:12:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
Message-ID: <20100810181209.GB4887@localhost>
References: <20100805163401.e9754032.akpm@linux-foundation.org>
 <20100806124452.GC4717@localhost>
 <20100809235652.7113.A69D9226@jp.fujitsu.com>
 <20100810135712.0eb34759@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100810135712.0eb34759@notabene>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 10, 2010 at 11:57:12AM +0800, Neil Brown wrote:
> On Tue, 10 Aug 2010 12:12:06 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > Subject: writeback: explicit low bound for vm.dirty_ratio
> > > From: Wu Fengguang <fengguang.wu@intel.com>
> > > Date: Thu Jul 15 10:28:57 CST 2010
> > > 
> > > Force a user visible low bound of 5% for the vm.dirty_ratio interface.
> > > 
> > > This is an interface change. When doing
> > > 
> > > 	echo N > /proc/sys/vm/dirty_ratio
> > > 
> > > where N < 5, the old behavior is pretend to accept the value, while
> > > the new behavior is to reject it explicitly with -EINVAL.  This will
> > > possibly break user space if they checks the return value.
> > 
> > Umm.. I dislike this change. Is there any good reason to refuse explicit 
> > admin's will? Why 1-4% is so bad? Internal clipping can be changed later
> > but explicit error behavior is hard to change later.
> 
> As a data-point, I had a situation a while back where I needed a value below
> 1 to get desired behaviour.  The system had lots of RAM and fairly slow
> write-back (over NFS) so a 'sync' could take minutes.

Jan, here is a use case to limit dirty pages on slow devices :)

> So I would much prefer allowing not only 1-4, but also fraction values!!!
> 
> I can see no justification at all for setting a lower bound of 5.  Even zero
> can be useful - for testing purposes mostly.

Neil, that's perfectly legitimate need which I overlooked.
It seems that the vm.dirty_bytes parameter will work for your case.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0B26B02AB
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:07:17 -0400 (EDT)
Date: Thu, 5 Aug 2010 16:08:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/13] writeback patches for 2.6.36
Message-Id: <20100805160801.a5e0afc1.akpm@linux-foundation.org>
In-Reply-To: <20100805161051.501816677@intel.com>
References: <20100805161051.501816677@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Aug 2010 00:10:51 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> These are writeback patches intended for 2.6.36.

I won't be here Friday.  I need to get my junk into mainline on Monday.
Everybody and his dog is working on writeback, which is good, but
there's a lot of flux here.

So, no, I think it's too late to be thinking about 2.6.36-rc1.  Let's
slow down a bit, review and test each other's proposals and work out
what we want to do in the longer term.  After we've done that, we can
calmly and carefully take a look to see if there are any nice goodies
which we want to slip into 2.6.36-rc3 or thereabouts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

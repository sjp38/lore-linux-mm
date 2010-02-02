Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3F4396B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 19:16:00 -0500 (EST)
Date: Mon, 1 Feb 2010 16:15:31 -0800
From: Chris Frost <frost@CS.UCLA.EDU>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100202001531.GA22196@frostnet.net>
References: <20100121054734.GC24236@localhost> <20100123040348.GC30844@frostnet.net> <20100123102222.GA6943@localhost> <20100125094228.f7ca1430.kamezawa.hiroyu@jp.fujitsu.com> <20100125024544.GA16462@localhost> <20100125223635.GC2822@frostnet.net> <20100126133217.GB25407@localhost> <20100131143142.GA11186@localhost> <20100201020639.GA27212@frostnet.net> <20100201021703.GA11260@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100201021703.GA11260@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 10:17:03AM +0800, Wu Fengguang wrote:
> On Sun, Jan 31, 2010 at 07:06:39PM -0700, Chris Frost wrote:
> > Look good?
> 
> OK :)

Great!

Do you have a feel for when you expect to have your tree ready for review?
We'd love to see this patch released soon; applications can start to use
libprefetch when this change is generally available.

-- 
Chris Frost
http://www.frostnet.net/chris/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

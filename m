Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEB16B00B2
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 09:13:16 -0400 (EDT)
Date: Thu, 4 Nov 2010 14:12:28 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 00/17] [RFC] soft and dynamic dirty throttling limits
Message-ID: <20101104131228.GA22718@lst.de>
References: <20100912154945.758129106@intel.com> <20101012141716.GA26702@infradead.org> <20101013030733.GV4681@dastard> <20101013082611.GA6733@localhost> <20101013092627.GY4681@dastard> <20101101062446.GK2715@dastard> <20101104034119.GA18910@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101104034119.GA18910@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2010 at 11:41:19AM +0800, Wu Fengguang wrote:
> I'm feeling relatively good about the first 14 patches to do IO-less
> balance_dirty_pages() and larger writeback chunk size. I'll repost
> them separately as v2 after returning to Shanghai.

Going for as small as possible patchsets is a pretty good idea.  Just
getting the I/O less balance_dirty_pages on it's own would be a really
good start, as that's one of the really criticial pieces of
infrastructure that a lot of people are waiting for.  Getting it into
linux-mm/linux-next ASAP so that it gets a lot of testing would be
highly useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

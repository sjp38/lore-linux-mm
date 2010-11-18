Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB0B6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:37:17 -0500 (EST)
Date: Thu, 18 Nov 2010 08:37:02 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
Message-ID: <20101118133702.GA18834@infradead.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117231143.GQ22876@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Michel Lespinasse <walken@google.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 10:11:43AM +1100, Dave Chinner wrote:
> Hence I think that avoiding ->page_mkwrite callouts is likely to
> break some filesystems in subtle, undetected ways.  IMO, regardless
> of what is done, it would be really good to start by writing a new
> regression test to exercise and encode the expected the mlock
> behaviour so we can detect regressions later on....

I think it would help if we could drink a bit of the test driven design
coolaid here. Michel, can you write some testcases where pages on a
shared mapping are mlocked, then dirtied and then munlocked, and then
written out using msync/fsync.  Anything that fails this test on
btrfs/ext4/gfs/xfs/etc obviously doesn't work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

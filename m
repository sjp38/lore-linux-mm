Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 457316B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:39:09 -0500 (EST)
Date: Thu, 18 Nov 2010 08:39:04 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
Message-ID: <20101118133904.GB18834@infradead.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <20101118054629.GA3339@amd>
 <2ADBEB7E-0EC8-4536-B556-0453A8E1D5FA@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ADBEB7E-0EC8-4536-B556-0453A8E1D5FA@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 05:43:06AM -0500, Theodore Tso wrote:
> Why is it at all important that mlock() force block allocation for sparse blocks?    It's  not at all specified in the mlock() API definition that it does that.
> 
> Are there really programs that assume that mlock() == fallocate()?!?

If there are programs that do they can't predate linux 2.6.15, and only
work on btrfs/ext4/xfs/etc, but not ext2/ext3/reiserfs.  Seems rather
unlikely to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

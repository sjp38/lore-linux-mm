Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6D64D8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:39:47 -0400 (EDT)
Date: Thu, 21 Apr 2011 00:39:40 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421043940.GC22423@infradead.org>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
 <20110421033325.GA13764@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421033325.GA13764@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 11:33:25AM +0800, Wu Fengguang wrote:
> I collected the writeback_single_inode() traces (patch attached for
> your reference) each for several test runs, and find much more
> I_DIRTY_PAGES after patchset. Dave, do you know why there are so many
> I_DIRTY_PAGES (or radix tag) remained after the XFS ->writepages() call,
> even for small files?

What is your defintion of a small file?  As soon as it has multiple
extents or holes there's absolutely no way to clean it with a single
writepage call.  Also XFS tries to operate as non-blocking as possible
if the non-blocking flag is set in the wbc, but that flag actually
seems to be dead these days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

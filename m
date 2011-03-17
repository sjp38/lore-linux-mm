Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 169DD8D003F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:52:20 -0400 (EDT)
Date: Thu, 17 Mar 2011 11:51:39 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110317155139.GA16195@infradead.org>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 17, 2011 at 08:46:23AM -0700, Curt Wohlgemuth wrote:
> But if one of one's goals is to provide some sort of disk isolation based on
> cgroup parameters, than having at most one stream of write requests
> effectively neuters the IO scheduler.

If you use any kind of buffered I/O you already fail in that respect.
Writeback from balance_dirty_page really is just the wort case right now
with more I/O supposed to be handled by the background threads.  So if
you want to implement isolation properly you need to track the
originator of the I/O between the copy to the pagecache and actual
writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

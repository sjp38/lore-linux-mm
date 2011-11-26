Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82AD26B002D
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 01:51:41 -0500 (EST)
Date: Fri, 25 Nov 2011 22:51:36 -0800
From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
	migreated without blocking within ->migratepage
Message-ID: <20111126065136.GA12631@hexapodia.org>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321635524-8586-5-git-send-email-mgorman@suse.de> <20111118213530.GA6323@redhat.com> <20111121111726.GA19415@suse.de> <20111121224545.GC8397@redhat.com> <20111122125906.GK19415@suse.de> <20111124011943.GO8397@redhat.com> <20111124122144.GR19415@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124122144.GR19415@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 24, 2011 at 12:21:44PM +0000, Mel Gorman wrote:
> On Thu, Nov 24, 2011 at 02:19:43AM +0100, Andrea Arcangeli wrote:
> > Yes also note, ironically this is likely to be a better test for this
> > without the __GFP_MOVABLE in block_dev.c. Even if we want it fixed,
> > maybe another source that reduces the non movable pages may be needed then.
> > 
> 
> I'm also running other tests to avoid tuning for just this test cases.
> Right now, the list looks like;
> 
> 1. postmark with something creating anonymous mappings in the background
> 2. plain USB writing while creating anonymous mappings

I've been testing the original case that started this thread -- writing
multiple GB to a USB attached, FAT, very slow SD card.

I'm currently running 7f80850d + "mm: Do not stall in synchronous
compaction for THP allocations" Mel's original patch.  With this patch I
cannot reproduce the hangs that I saw.  I haven't retried without the
patch to confirm that they're reproducible, though.

someone asked about CONFIG_NUMA; I have CONFIG_NUMA=y.

I can reboot this weekend; what patches should I test with next?

-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

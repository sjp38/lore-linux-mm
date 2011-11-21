Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 195666B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 07:57:23 -0500 (EST)
Date: Mon, 21 Nov 2011 12:57:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/8] Revert "mm: compaction: make isolate_lru_page()
 filter-aware"
Message-ID: <20111121125717.GE19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321732460-14155-7-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321732460-14155-7-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On Sat, Nov 19, 2011 at 08:54:18PM +0100, Andrea Arcangeli wrote:
> This reverts commit
> 39deaf8585152f1a35c1676d3d7dc6ae0fb65967.
> 
> PageDirty is non blocking for compaction (unlike for
> mm/vmscan.c:may_writepage) so async compaction should include it.
> 

It blocks if fallback_migrate_page() is used which happens if the
underlying filesystem does not support ->migratepage.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

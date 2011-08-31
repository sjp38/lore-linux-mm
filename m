Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E96386B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 07:19:58 -0400 (EDT)
Date: Wed, 31 Aug 2011 13:19:54 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 2/3] compaction: compact unevictable page
Message-ID: <20110831111954.GB17512@redhat.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Sun, Nov 13, 2011 at 01:37:42AM +0900, Minchan Kim wrote:
> Now compaction doesn't handle mlocked page as it uses __isolate_lru_page
> which doesn't consider unevicatable page. It has been used by just lumpy so
> it was pointless that it isolates unevictable page. But the situation is
> changed. Compaction could handle unevictable page and it can help getting
> big contiguos pages in fragment memory by many pinned page with mlock.

This may result in applications unexpectedly faulting and waiting on
mlocked pages under migration.  I wonder how realtime people feel
about that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC7336B0170
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 11:03:05 -0400 (EDT)
Date: Wed, 31 Aug 2011 17:03:00 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 3/3] compaction accouting fix
Message-ID: <20110831150300.GC19122@redhat.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <282a4531f23c5e35cfddf089f93559130b4bb660.1321112552.git.minchan.kim@gmail.com>
 <20110831113710.GC17512@redhat.com>
 <20110831145651.GA2198@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110831145651.GA2198@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Wed, Aug 31, 2011 at 11:56:51PM +0900, Minchan Kim wrote:
> On Wed, Aug 31, 2011 at 01:37:10PM +0200, Johannes Weiner wrote:
> > It's a teensy-bit awkward that isolate_migratepages() can return
> > success without actually isolating any new pages, just because there
> > are still some pages left from a previous run (cc->nr_migratepages is
> > maintained across isolation calls).
> 
> If migrate_pages fails, we reset cc->nr_migratepages to zero in compact_zone.
> Am I missing something?

Brainfart on my side, sorry.  It's all good, then :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

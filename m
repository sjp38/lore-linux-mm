Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1AB966B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:52:19 -0500 (EST)
Date: Thu, 20 Dec 2012 10:52:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: count compaction events only if
 compaction is enabled
Message-ID: <20121220105214.GC10819@suse.de>
References: <alpine.LNX.2.00.1212201118080.17797@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212201118080.17797@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 20, 2012 at 11:21:34AM +0100, Jiri Kosina wrote:
> On configs which have CONFIG_CMA but no CONFIG_COMPACTION, 
> isolate_migratepages_range() and isolate_freepages_block() must not 
> account for COMPACTFREE_SCANNED and COMPACTISOLATED events (those 
> constants are even undefined in such case, causing a build error).
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Minchan has a similar patch in the works that defines count_compact_events()
similar to count_vm_numa_events(). It just needs a small correction. The
fixed version would avoid having an #ifdef in the middle of the function
which is cosmetically a bit nicer.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

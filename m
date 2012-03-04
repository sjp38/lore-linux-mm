Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8B0586B004D
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 02:11:39 -0500 (EST)
Received: by dakp5 with SMTP id p5so3993537dak.8
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 23:11:38 -0800 (PST)
Date: Sun, 4 Mar 2012 16:11:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: don't set __GFP_WRITE on ramfs/sysfs writes
Message-ID: <20120304071129.GB7824@barrios>
References: <20120302061035.GA2344@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120302061035.GA2344@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 02, 2012 at 02:10:35PM +0800, Fengguang Wu wrote:
> There is not much of a point in skipping zones during allocation based
> on the dirty usage which they'll never contribute to. And we'd like to
> avoid page reclaim waits when writing to ramfs/sysfs etc.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

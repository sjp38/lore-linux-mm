Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0AD6B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 00:03:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x17so2950731pgi.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 21:03:01 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y11si685244plg.82.2017.02.27.21.02.59
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 21:03:00 -0800 (PST)
Date: Tue, 28 Feb 2017 14:02:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 5/6] mm: enable MADV_FREE for swapless system
Message-ID: <20170228050256.GC2702@bbox>
References: <cover.1487965799.git.shli@fb.com>
 <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
MIME-Version: 1.0
In-Reply-To: <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 01:31:48PM -0800, Shaohua Li wrote:
> Now MADV_FREE pages can be easily reclaimed even for swapless system. We
> can safely enable MADV_FREE for all systems.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

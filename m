Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79B4444060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:16:18 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gh4so9055085wjb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:16:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p26si13792712wrp.329.2017.02.17.08.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:16:17 -0800 (PST)
Date: Fri, 17 Feb 2017 11:16:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 4/7] mm: enable MADV_FREE for swapless system
Message-ID: <20170217161613.GD23735@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <a69e166d626711a6cb3ebbd2f5c9f898e2bd2d8d.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a69e166d626711a6cb3ebbd2f5c9f898e2bd2d8d.1487100204.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Tue, Feb 14, 2017 at 11:36:10AM -0800, Shaohua Li wrote:
> Now MADV_FREE pages can be easily reclaimed even for swapless system. We
> can safely enable MADV_FREE for all systems.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5318C6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 20:25:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so14221806pgi.4
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:25:20 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v75si5799117pfa.126.2017.02.23.17.25.18
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 17:25:19 -0800 (PST)
Date: Fri, 24 Feb 2017 10:25:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V4 1/6] mm: delete unnecessary TTU_* flags
Message-ID: <20170224012516.GB9818@bbox>
References: <cover.1487788131.git.shli@fb.com>
 <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 10:50:39AM -0800, Shaohua Li wrote:
> Johannes pointed out TTU_LZFREE is unnecessary. It's true because we
> always have the flag set if we want to do an unmap. For cases we don't
> do an unmap, the TTU_LZFREE part of code should never run.
> 
> Also the TTU_UNMAP is unnecessary. If no other flags set (for
> example, TTU_MIGRATION), an unmap is implied.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

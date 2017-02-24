Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8F76B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 21:14:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so15731787pgi.7
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:14:52 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a2si5905656pln.223.2017.02.23.18.14.50
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 18:14:51 -0800 (PST)
Date: Fri, 24 Feb 2017 11:13:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V4 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170224021321.GE9818@bbox>
References: <cover.1487788131.git.shli@fb.com>
 <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
MIME-Version: 1.0
In-Reply-To: <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 10:50:44AM -0800, Shaohua Li wrote:
> show MADV_FREE pages info of each vma in smaps. The interface is for
> diganose or monitoring purpose, userspace could use it to understand
> what happens in the application. Since userspace could dirty MADV_FREE
> pages without notice from kernel, this interface is the only place we
> can get accurate accounting info about MADV_FREE pages.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

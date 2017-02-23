Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C54D96B0388
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:22:28 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p36so18084211wrc.7
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:22:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j59si6629984wrj.283.2017.02.23.08.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 08:22:27 -0800 (PST)
Date: Thu, 23 Feb 2017 11:16:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170223161629.GD4031@cmpxchg.org>
References: <cover.1487788131.git.shli@fb.com>
 <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

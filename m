Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942CB6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 22:24:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h72so128146989pfd.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 19:24:18 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id o71si438762pfi.195.2017.02.27.19.24.16
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 19:24:17 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487965799.git.shli@fb.com> <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
In-Reply-To: <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Date: Tue, 28 Feb 2017 11:23:57 +0800
Message-ID: <06f201d29172$196e6450$4c4b2cf0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shaohua Li' <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org


On February 25, 2017 5:32 AM Shaohua Li wrote: 
> 
> show MADV_FREE pages info of each vma in smaps. The interface is for
> diganose or monitoring purpose, userspace could use it to understand
> what happens in the application. Since userspace could dirty MADV_FREE
> pages without notice from kernel, this interface is the only place we
> can get accurate accounting info about MADV_FREE pages.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

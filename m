Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6AB06B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 22:30:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so18164685pgz.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 19:30:03 -0800 (PST)
Received: from out0-145.mail.aliyun.com (out0-145.mail.aliyun.com. [140.205.0.145])
        by mx.google.com with ESMTP id n19si6049652pgk.293.2017.02.23.19.30.01
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 19:30:02 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487788131.git.shli@fb.com> <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
In-Reply-To: <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
Subject: Re: [PATCH V4 1/6] mm: delete unnecessary TTU_* flags
Date: Fri, 24 Feb 2017 11:29:54 +0800
Message-ID: <01d601d28e4e$44a43090$cdec91b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shaohua Li' <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On February 23, 2017 2:51 AM Shaohua Li wrote: 
> 
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
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

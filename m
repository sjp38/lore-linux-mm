Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 299EE6B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:54:36 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id g6so33194489igt.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 23:54:36 -0800 (PST)
Received: from out4133-2.mail.aliyun.com (out4133-2.mail.aliyun.com. [42.120.133.2])
        by mx.google.com with ESMTP id l10si15257019iod.158.2016.02.25.23.54.34
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 23:54:35 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160225092315.GD17573@dhcp22.suse.cz> <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Date: Fri, 26 Feb 2016 15:54:19 +0800
Message-ID: <009a01d1706a$e666dc00$b3349400$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hugh Dickins' <hughd@google.com>, 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>

> 
> It didn't really help, I'm afraid: it reduces the actual number of OOM
> kills which occur before the job is terminated, but doesn't stop the
> job from being terminated very soon.
> 
> I also tried Hillf's patch (separately) too, but as you expected,
> it didn't seem to make any difference.
> 
Perhaps non-costly means NOFAIL as shown by folding the two
patches into one. Can it make any sense?

thanks
Hillf
--- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
+++ b/mm/page_alloc.c	Fri Feb 26 15:18:55 2016
@@ -3113,6 +3113,8 @@ should_reclaim_retry(gfp_t gfp_mask, uns
 	struct zone *zone;
 	struct zoneref *z;
 
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		return true;
 	/*
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 782F06B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:38:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u62so69731612pfk.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:38:15 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id 3si6295580pgi.256.2017.03.01.19.38.13
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:38:14 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-10-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-10-hannes@cmpxchg.org>
Subject: Re: [PATCH 9/9] mm: remove unnecessary back-off function when retrying page reclaim
Date: Thu, 02 Mar 2017 11:37:57 +0800
Message-ID: <078401d29306$628fbe00$27af3a00$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


On March 01, 2017 5:40 AM Johannes Weiner wrote:
> 
> The backoff mechanism is not needed. If we have MAX_RECLAIM_RETRIES
> loops without progress, we'll OOM anyway; backing off might cut one or
> two iterations off that in the rare OOM case. If we have intermittent
> success reclaiming a few pages, the backoff function gets reset also,
> and so is of little help in these scenarios.
> 
> We might want a backoff function for when there IS progress, but not
> enough to be satisfactory. But this isn't that. Remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

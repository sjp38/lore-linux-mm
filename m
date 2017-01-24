Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 420F36B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 21:34:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so219990800pgc.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:34:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l3si17518662pln.71.2017.01.23.18.34.20
        for <linux-mm@kvack.org>;
        Mon, 23 Jan 2017 18:34:21 -0800 (PST)
Date: Tue, 24 Jan 2017 11:34:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170124023417.GB24523@bbox>
References: <1485183010-9276-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
In-Reply-To: <1485183010-9276-1-git-send-email-ysxie@foxmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Mon, Jan 23, 2017 at 10:50:10PM +0800, ysxie@foxmail.com wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
> 
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75D736B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:52:16 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so36901747wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:52:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si26612115wrc.113.2017.01.25.03.52.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 03:52:15 -0800 (PST)
Date: Wed, 25 Jan 2017 12:52:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170125115212.GK32377@dhcp22.suse.cz>
References: <1485183010-9276-1-git-send-email-ysxie@foxmail.com>
 <20170125114753.GJ32377@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125114753.GJ32377@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 25-01-17 12:47:53, Michal Hocko wrote:
> On Mon 23-01-17 22:50:10, ysxie@foxmail.com wrote:
> > From: Yisheng Xie <xieyisheng1@huawei.com>
> > 
> > This patch is to extends soft offlining framework to support
> > non-lru page, which already support migration after
> > commit bda807d44454 ("mm: migrate: support non-lru movable page
> > migration")
> > 
> > When memory corrected errors occur on a non-lru movable page,
> > we can choose to stop using it by migrating data onto another
> > page and disable the original (maybe half-broken) one.
> > 
> > Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > Suggested-by: Minchan Kim <minchan@kernel.org>
> > Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> This doesn't compile with CONFIG_MIGRATION=n
> 
> mm/memory-failure.c: In function '__soft_offline_page':
> mm/memory-failure.c:1656:3: error: implicit declaration of function 'isolate_movable_page' [-Werror=implicit-function-declaration]
>    ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>    ^
> cc1: some warnings being treated as errors

OK, I have missed
http://lkml.kernel.org/r/1485340563-60785-1-git-send-email-xieyisheng1@huawei.com
so please scratch this one.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

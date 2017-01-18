Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 786B26B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:51:52 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so1482631wjc.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:51:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si16926476wrb.95.2017.01.18.01.51.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:51:51 -0800 (PST)
Date: Wed, 18 Jan 2017 10:51:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170118095148.GK7015@dhcp22.suse.cz>
References: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 18-01-17 12:00:54, Yisheng Xie wrote:
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
> 
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.

soft_offline_movable_page duplicates quite a lot from
__soft_offline_page. Would it be better to handle both cases in
__soft_offline_page?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

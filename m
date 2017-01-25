Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 447A06B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:48:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so289653237pgf.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:48:48 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w64si5963284pgb.270.2017.01.25.15.48.46
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 15:48:47 -0800 (PST)
Date: Thu, 26 Jan 2017 08:48:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/migration: make isolate_movable_page always defined
Message-ID: <20170125234845.GB20953@bbox>
References: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed, Jan 25, 2017 at 06:36:03PM +0800, Yisheng Xie wrote:
> Define isolate_movable_page as a static inline function when
> CONFIG_MIGRATION is not enable. It should return false
> here which means failed to isolate movable pages.
> 
> This patch do not have any functional change but to resolve compile
> error caused by former commit "HWPOISON: soft offlining for non-lru
> movable page" with CONFIG_MIGRATION disabled.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

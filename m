Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC0B56B0033
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:13:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x4so8349487wme.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:13:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si16826652wrb.227.2017.01.30.07.13.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 07:13:34 -0800 (PST)
Date: Mon, 30 Jan 2017 16:13:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 1/2] mm/migration: make isolate_movable_page always
 defined
Message-ID: <20170130151331.GA5311@dhcp22.suse.cz>
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
 <1485356738-4831-2-git-send-email-ysxie@foxmail.com>
 <20170126091833.GC6590@dhcp22.suse.cz>
 <588F54E8.5040303@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <588F54E8.5040303@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Mon 30-01-17 22:59:52, Yisheng Xie wrote:
> Hii 1/4 ? Michali 1/4 ?
> Sorry for late reply.
> 
> On 01/26/2017 05:18 PM, Michal Hocko wrote:
> > On Wed 25-01-17 23:05:37, ysxie@foxmail.com wrote:
> >> From: Yisheng Xie <xieyisheng1@huawei.com>
> >>
> >> Define isolate_movable_page as a static inline function when
> >> CONFIG_MIGRATION is not enable. It should return false
> >> here which means failed to isolate movable pages.
> >>
> >> This patch do not have any functional change but prepare for
> >> later patch.
> > I think it would make more sense to make isolate_movable_page return int
> > and have the same semantic as __isolate_lru_page. This would be a better
> > preparatory patch for the later work.
> Yes, I think you are right, it is better to make isolate_movable_page return int
> just as what isolate_lru_page do, to make a better code style.
> 
> It seems Andrew had already merged the fixed patch from Arnd Bergmann,
> Maybe I can rewrite it in a later patch if it is suitable :)

I guess Andrew can just drop the current series with the folow up fixes
and wait for your newer version.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

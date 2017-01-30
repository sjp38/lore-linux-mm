Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6126B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:00:03 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y196so153481550ity.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:00:03 -0800 (PST)
Received: from smtpbgau1.qq.com (smtpbgau1.qq.com. [54.206.16.166])
        by mx.google.com with ESMTPS id k185si8250140itb.12.2017.01.30.07.00.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 07:00:02 -0800 (PST)
Subject: Re: [PATCH v4 1/2] mm/migration: make isolate_movable_page always
 defined
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
 <1485356738-4831-2-git-send-email-ysxie@foxmail.com>
 <20170126091833.GC6590@dhcp22.suse.cz>
From: Yisheng Xie <ysxie@foxmail.com>
Message-ID: <588F54E8.5040303@foxmail.com>
Date: Mon, 30 Jan 2017 22:59:52 +0800
MIME-Version: 1.0
In-Reply-To: <20170126091833.GC6590@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Hii 1/4 ? Michali 1/4 ?
Sorry for late reply.

On 01/26/2017 05:18 PM, Michal Hocko wrote:
> On Wed 25-01-17 23:05:37, ysxie@foxmail.com wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> Define isolate_movable_page as a static inline function when
>> CONFIG_MIGRATION is not enable. It should return false
>> here which means failed to isolate movable pages.
>>
>> This patch do not have any functional change but prepare for
>> later patch.
> I think it would make more sense to make isolate_movable_page return int
> and have the same semantic as __isolate_lru_page. This would be a better
> preparatory patch for the later work.
Yes, I think you are right, it is better to make isolate_movable_page return int
just as what isolate_lru_page do, to make a better code style.

It seems Andrew had already merged the fixed patch from Arnd Bergmann,
Maybe I can rewrite it in a later patch if it is suitable :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7C266B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 13:36:40 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r9so4569169ywg.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:36:40 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id r186si2177759ybr.275.2016.07.27.10.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 10:36:40 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id u134so4260258ywg.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:36:39 -0700 (PDT)
Date: Wed, 27 Jul 2016 13:36:38 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/memblock.c: fix index adjustment error in
 __next_mem_range_rev()
Message-ID: <20160727173638.GF4144@mtj.duckdns.org>
References: <42A378E55677204FAE257FE7EED241CB7E8EF129@CN-MBX01.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42A378E55677204FAE257FE7EED241CB7E8EF129@CN-MBX01.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu@htc.com
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, ard.biesheuvel@linaro.org, weiyang@linux.vnet.ibm.com, dev@g0hl1n.net, david@gibson.dropbear.id.au, linux-mm@kvack.org, zhiyuan_zhu@htc.com

Hello,

On Wed, Jul 27, 2016 at 06:49:40AM +0000, zijun_hu@htc.com wrote:
> patch 0001 can fix the issue and pass test successfully, please help to review
> and phase-in it
> patch 0002 is used to verify the solution only and is provided for explaining
> test method, please don't apply it

Great.

> for __next_mem_range_rev(), it don't iterate through memory regions contained
> in type_a in reversed order rightly if its parameter type_b == NULL
> moreover, it will cause mass error loops if macro for_each_mem_range_rev is
> called with parameter type_b == NULL
> 
> the patch 0001 corrects region index idx_a adjustment and initialize idx_b
> to 0 to promise getting the last reversed region correctly if parameter
> type_b == NULL as showed below
> 
> my test method is simple, namely, dump all types of regions with right kernel
> interface and fixed __next_mem_range separately ,then check whether
> fixed__next_mem_range achieve desired purpose, see test patch segments
> below or entire patch 0002 for more info

It'd be better to include how you tested in the patch description.

> fix patch 0001 is showed as follows
> 
> From da2f3cafab9632d59261cf0801f62e909d0bfde1 Mon Sep 17 00:00:00 2001
> From: zijun_hu <zijun_hu@htc.com>
> Date: Mon, 25 Jul 2016 15:06:57 +0800
> Subject: [PATCH 1/2] mm/memblock.c: fix index adjustment error in
>  __next_mem_range_rev()
> 
> fix region index adjustment error when parameter type_b of
> __next_mem_range_rev() == NULL
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

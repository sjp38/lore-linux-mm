Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2C266B0005
	for <linux-mm@kvack.org>; Sun,  5 Aug 2018 01:31:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w14-v6so6305210pfn.13
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 22:31:00 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80132.outbound.protection.outlook.com. [40.107.8.132])
        by mx.google.com with ESMTPS id z62-v6si7609979pgz.640.2018.08.04.22.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 04 Aug 2018 22:30:58 -0700 (PDT)
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
 <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
 <20180805000305.GC3183@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e5d67774-a006-e533-d928-64a4407cbb16@virtuozzo.com>
Date: Sun, 5 Aug 2018 08:30:43 +0300
MIME-Version: 1.0
In-Reply-To: <20180805000305.GC3183@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05.08.2018 03:03, Matthew Wilcox wrote:
> On Sat, Aug 04, 2018 at 09:42:05PM +0300, Kirill Tkhai wrote:
>> This is exactly the thing the patch makes. Instead of inserting a shrinker pointer
>> to idr, it inserts a fake value SHRINKER_REGISTERING there. The patch makes impossible
>> to dereference a shrinker unless it's completely registered. 
> 
> -       id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
> +       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
> 
> Instead:
> 
> +       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);
> 
> ... and the rest of your patch becomes even simpler.

The patch, we are discussing at the moment, does *exactly* this:

https://lkml.org/lkml/2018/8/3/588

It looks like you missed this hunk in the patch.

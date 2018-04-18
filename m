Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E93E26B000C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:27:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q15-v6so1982657itb.7
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:27:17 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0107.outbound.protection.outlook.com. [104.47.1.107])
        by mx.google.com with ESMTPS id x189-v6si1462655ite.42.2018.04.18.07.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 07:27:16 -0700 (PDT)
Subject: Re: [PATCH v2 01/12] mm: Assign id to every memcg-aware shrinker
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
 <201804182314.IIG86990.MFVJSFQLFOtHOO@I-love.SAKURA.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b544689c-718c-abda-889c-5ec5eb755854@virtuozzo.com>
Date: Wed, 18 Apr 2018 17:27:08 +0300
MIME-Version: 1.0
In-Reply-To: <201804182314.IIG86990.MFVJSFQLFOtHOO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 18.04.2018 17:14, Tetsuo Handa wrote:
> Kirill Tkhai wrote:
>> The patch introduces shrinker::id number, which is used to enumerate
>> memcg-aware shrinkers. The number start from 0, and the code tries
>> to maintain it as small as possible.
>>
>> This will be used as to represent a memcg-aware shrinkers in memcg
>> shrinkers map.
> 
> I'm not reading this thread. But is there reason "id" needs to be managed
> using smallest numbers? Can't we use address of shrinker object as "id"
> (which will be sparse bitmap, and would be managed using linked list for now)?

Yes, it's needed to have the smallest numbers, as next patches introduce
per-memcg bitmap containing ids of shrinkers.

Kirill

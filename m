Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDA1B6B000D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:38:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u8so2176721pfm.21
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:38:38 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0090.outbound.protection.outlook.com. [104.47.1.90])
        by mx.google.com with ESMTPS id a12-v6si16416380plt.606.2018.03.26.08.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:38:37 -0700 (PDT)
Subject: Re: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
 <20180324184009.dyjlt4rj4b6y6sz3@esperanza>
 <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
 <20180326151406.GE10912@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a0152b4b-28f9-5970-a972-8649a2b81a6a@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:38:29 +0300
MIME-Version: 1.0
In-Reply-To: <20180326151406.GE10912@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 26.03.2018 18:14, Matthew Wilcox wrote:
> On Mon, Mar 26, 2018 at 06:09:35PM +0300, Kirill Tkhai wrote:
>>> AFAIK ida always allocates the smallest available id so you don't need
>>> to keep track of bitmap_id_start.
>>
>> I saw mnt_alloc_group_id() does the same, so this was the reason, the additional
>> variable was used. Doesn't this gives a good advise to ida and makes it find
>> a free id faster?
> 
> No, it doesn't help the IDA in the slightest.  I have a patch in my
> tree to delete that silliness from mnt_alloc_group_id(); just haven't
> submitted it yet.

Ok, then I'll remove this trick.

Thanks,
Kirill

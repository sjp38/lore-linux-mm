Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 689986B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:29:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e139so17526442oib.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:29:01 -0700 (PDT)
Received: from out1134-251.mail.aliyun.com (out1134-251.mail.aliyun.com. [42.120.134.251])
        by mx.google.com with ESMTP id w25si9041349ioi.161.2016.07.27.14.28.59
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 14:29:00 -0700 (PDT)
Message-ID: <57992927.8050904@emindsoft.com.cn>
Date: Thu, 28 Jul 2016 05:35:35 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: page-flags: Use bool return value instead of int
 for all XXPageXXX functions
References: <1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn> <13e3f511-e14c-2e4d-9627-4a85c65de931@suse.cz>
In-Reply-To: <13e3f511-e14c-2e4d-9627-4a85c65de931@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, minchan@kernel.org, mgorman@techsingularity.net, mhocko@suse.com
Cc: gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 7/26/16 15:30, Vlastimil Babka wrote:
> On 07/24/2016 06:56 AM, chengang@emindsoft.com.cn wrote:
>> From: Chen Gang <gang.chen.5i5j@gmail.com>
>>
>> For pure bool function's return value, bool is a little better more or
>> less than int.
> 
> That's not exactly a bulletproof justification... At least provide a scripts/bloat-o-meter output?
> 
>> Under source root directory, use `grep -rn Page * | grep "\<int\>"` to
>> find the area that need be changed.
>>
>> For the related macro function definiations (e.g. TESTPAGEFLAG), they
>> use xxx_bit which should be pure bool functions, too. But under most of
>> architectures, xxx_bit are return int, which need be changed next.
> 
> Sounds like a large task. And until we know the arches will agree with this, this patch will bring just inconsistency?
> 

For me, for bool function, we can still return int value instead of bool,
e.g. *_test() will return int under quite a few of archs, and Page*()
use *_test(), but we need not use '!!' to cast the return value to bool.

And for me, we can still use int variable to catch the return value of
bool function, but it will be better to be improved. So in this patch, I
also modify all related areas as far as I can find.

All together, for me, in the worst case, if I really missed any areas or
any functions: it is still better to be improved, but for building and
running, it is no negative effect.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

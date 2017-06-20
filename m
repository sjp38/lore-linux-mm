Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30F9B6B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:39:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u62so23600974pgb.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:39:19 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id p71si9188096pfd.209.2017.06.19.18.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 18:39:18 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id u62so36590123pgb.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:39:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87y3snajd2.fsf@rasmusvillemoes.dk>
References: <20170619135418.8580-1-haolee.swjtu@gmail.com> <e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz>
 <87y3snajd2.fsf@rasmusvillemoes.dk>
From: Hao Lee <haolee.swjtu@gmail.com>
Date: Tue, 20 Jun 2017 09:39:17 +0800
Message-ID: <CA+PpKPnuWDZL_KgoBZhokhSA_9Ydh=xmhUc3sPufAyaJs4NtLQ@mail.gmail.com>
Subject: Re: [PATCH] mm: remove a redundant condition in the for loop
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 20, 2017 at 3:05 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On Mon, Jun 19 2017, Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> On 06/19/2017 03:54 PM, Hao Lee wrote:
>>> The variable current_order decreases from MAX_ORDER-1 to order, so the
>>> condition current_order <= MAX_ORDER-1 is always true.
>>>
>>> Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
>>
>> Sounds right.
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> current_order and order are both unsigned, and if order==0,
> current_order >= order is always true, and we may decrement
> current_order past 0 making it UINT_MAX... A comment would be in order,
> though.

Thanks, I didn't notice unsigned subtraction. Sorry about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

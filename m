Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9055C6B02F4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:23:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y19so18416843wrc.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:23:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si5626891wrh.278.2017.06.19.13.23.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 13:23:46 -0700 (PDT)
Subject: Re: [PATCH] mm: remove a redundant condition in the for loop
References: <20170619135418.8580-1-haolee.swjtu@gmail.com>
 <e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz>
 <87y3snajd2.fsf@rasmusvillemoes.dk>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <73d7a087-1a5d-57ba-7026-5756b8a92381@suse.cz>
Date: Mon, 19 Jun 2017 22:23:03 +0200
MIME-Version: 1.0
In-Reply-To: <87y3snajd2.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Hao Lee <haolee.swjtu@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19/2017 09:05 PM, Rasmus Villemoes wrote:
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

Doh, right. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

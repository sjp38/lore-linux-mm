Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id C46B46B025E
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 17:32:58 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id 206so45610461ybz.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:32:58 -0800 (PST)
Received: from mail-yb0-x234.google.com (mail-yb0-x234.google.com. [2607:f8b0:4002:c09::234])
        by mx.google.com with ESMTPS id l207si7157625ybl.294.2016.11.07.14.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 14:32:58 -0800 (PST)
Received: by mail-yb0-x234.google.com with SMTP id v78so61041896ybe.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:32:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161107141919.fe50cef419918c7a4660f3c2@linux-foundation.org>
References: <1478553075-120242-1-git-send-email-thgarnie@google.com> <20161107141919.fe50cef419918c7a4660f3c2@linux-foundation.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 7 Nov 2016 14:32:56 -0800
Message-ID: <CAJcbSZGO1oVf2cQeCO2_qiUrNdSckhwDSah4sqnnc388J2Rruw@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] memcg: Prevent memcg caches to be both OFF_SLAB & OBJFREELIST_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, Nov 7, 2016 at 2:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon,  7 Nov 2016 13:11:14 -0800 Thomas Garnier <thgarnie@google.com> wrote:
>
>> From: Greg Thelen <gthelen@google.com>
>>
>> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
>> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
>> CFLGS_OBJFREELIST_SLAB.
>>
>> The original kmem_cache is created early making OFF_SLAB not possible.
>> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
>> is enabled it will try to enable it first under certain conditions.
>> Given kmem_cache(sys) reuses the original flag, you can have both flags
>> at the same time resulting in allocation failures and odd behaviors.
>
> Can we please have a better description of the problems which this bug
> causes?  Without this info it's unclear to me which kernel version(s)
> need the fix.
>
> Given that the bug is 6 months old I'm assuming "not very urgent".
>

I will add more details and send another round.

>> This fix discards allocator specific flags from memcg before calling
>> create_cache.
>>
>> Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Tested-by: Thomas Garnier <thgarnie@google.com>
>
> This should have had your signed-off-by, as you were on the delivery
> path.  I've made that change.

Thanks Andrew.


-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

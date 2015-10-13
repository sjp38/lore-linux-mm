Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 58C506B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:07:03 -0400 (EDT)
Received: by iow1 with SMTP id 1so14135394iow.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:07:03 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id i77si2013940ioi.109.2015.10.13.02.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 02:07:02 -0700 (PDT)
Received: by iofl186 with SMTP id l186so14022061iof.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:07:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013080044.GA587@swordfish>
References: <1444717862-27234-1-git-send-email-zhuhui@xiaomi.com> <20151013080044.GA587@swordfish>
From: Hui Zhu <teawater@gmail.com>
Date: Tue, 13 Oct 2015 17:06:22 +0800
Message-ID: <CANFwon0VZKOCRFt=OokjnnDb6ZEioyxd-UVhUqAQZBsMP6xz_g@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: remove unless line in obj_free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks.  I will post a new version later.

Best,
Hui

On Tue, Oct 13, 2015 at 4:00 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (10/13/15 14:31), Hui Zhu wrote:
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>
> s/unless/useless/
>
> other than that
>
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>
>         -ss
>
>> ---
>>  mm/zsmalloc.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index f135b1b..c7338f0 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -1428,8 +1428,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
>>       struct page *first_page, *f_page;
>>       unsigned long f_objidx, f_offset;
>>       void *vaddr;
>> -     int class_idx;
>> -     enum fullness_group fullness;
>>
>>       BUG_ON(!obj);
>>
>> @@ -1437,7 +1435,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
>>       obj_to_location(obj, &f_page, &f_objidx);
>>       first_page = get_first_page(f_page);
>>
>> -     get_zspage_mapping(first_page, &class_idx, &fullness);
>>       f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
>>
>>       vaddr = kmap_atomic(f_page);
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

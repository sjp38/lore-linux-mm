Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id B67FD6B0037
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 06:46:44 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so519953wes.38
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 03:46:43 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id fy4si22604231wjc.33.2013.12.06.03.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 03:46:43 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id a1so523221wgh.29
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 03:46:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52A191D3.5050507@cn.fujitsu.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1386319310-28016-3-git-send-email-iamjoonsoo.kim@lge.com>
	<52A191D3.5050507@cn.fujitsu.com>
Date: Fri, 6 Dec 2013 20:46:43 +0900
Message-ID: <CAAmzW4MXZyBA-RrVhL2QcFQfddBRoyROhO6xTYgQ0wJsMO6PmQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/migrate: remove putback_lru_pages, fix comment on putback_movable_pages
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2013/12/6 Zhang Yanfei <zhangyanfei@cn.fujitsu.com>:
> Hello
>
> On 12/06/2013 04:41 PM, Joonsoo Kim wrote:
>> Some part of putback_lru_pages() and putback_movable_pages() is
>> duplicated, so it could confuse us what we should use.
>> We can remove putback_lru_pages() since it is not really needed now.
>> This makes us undestand and maintain the code more easily.
>>
>> And comment on putback_movable_pages() is stale now, so fix it.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>> index f5096b5..7782b74 100644
>> --- a/include/linux/migrate.h
>> +++ b/include/linux/migrate.h
>> @@ -35,7 +35,6 @@ enum migrate_reason {
>>
>>  #ifdef CONFIG_MIGRATION
>>
>> -extern void putback_lru_pages(struct list_head *l);
>>  extern void putback_movable_pages(struct list_head *l);
>>  extern int migrate_page(struct address_space *,
>>                       struct page *, struct page *, enum migrate_mode);
>> @@ -59,7 +58,6 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
>>  #else
>>
>>  static inline void putback_lru_pages(struct list_head *l) {}
>
> If you want to remove the function, this should be removed, right?

Hello, Zhang.

Oop... It's my mistake. I will send v2.
Thanks for finding this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

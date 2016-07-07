Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD134828E1
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:08:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so7196686lfg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:08:24 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id kv8si573169wjb.294.2016.07.07.02.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:08:23 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so3941333wmz.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:08:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160707074420.GE18072@bbox>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
 <1467786233-4481-8-git-send-email-opensource.ganesh@gmail.com> <20160707074420.GE18072@bbox>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Thu, 7 Jul 2016 17:08:22 +0800
Message-ID: <CADAEsF-X8Jrff6cMUvvb320kkPZ-p5g6ZX23nck_=B=T75dW3w@mail.gmail.com>
Subject: Re: [PATCH v3 8/8] mm/zsmalloc: add per-class compact trace event
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

2016-07-07 15:44 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hello Ganesh,
>
> On Wed, Jul 06, 2016 at 02:23:53PM +0800, Ganesh Mahendran wrote:
>> add per-class compact trace event to get scanned objects and freed pages
>> number.
>> trace log is like below:
>> ----
>>          kswapd0-629   [001] ....   293.161053: zs_compact_start: pool zram0
>>          kswapd0-629   [001] ....   293.161056: zs_compact: class 254: 0 objects scanned, 0 pages freed
>>          kswapd0-629   [001] ....   293.161057: zs_compact: class 202: 0 objects scanned, 0 pages freed
>>          kswapd0-629   [001] ....   293.161062: zs_compact: class 190: 1 objects scanned, 3 pages freed
>>          kswapd0-629   [001] ....   293.161063: zs_compact: class 168: 0 objects scanned, 0 pages freed
>>          kswapd0-629   [001] ....   293.161065: zs_compact: class 151: 0 objects scanned, 0 pages freed
>>          kswapd0-629   [001] ....   293.161073: zs_compact: class 144: 4 objects scanned, 8 pages freed
>>          kswapd0-629   [001] ....   293.161087: zs_compact: class 126: 20 objects scanned, 10 pages freed
>>          kswapd0-629   [001] ....   293.161095: zs_compact: class 111: 6 objects scanned, 8 pages freed
>>          kswapd0-629   [001] ....   293.161122: zs_compact: class 107: 27 objects scanned, 27 pages freed
>>          kswapd0-629   [001] ....   293.161157: zs_compact: class 100: 36 objects scanned, 24 pages freed
>>          kswapd0-629   [001] ....   293.161173: zs_compact: class  94: 10 objects scanned, 15 pages freed
>>          kswapd0-629   [001] ....   293.161221: zs_compact: class  91: 30 objects scanned, 40 pages freed
>>          kswapd0-629   [001] ....   293.161256: zs_compact: class  83: 120 objects scanned, 30 pages freed
>>          kswapd0-629   [001] ....   293.161266: zs_compact: class  76: 8 objects scanned, 8 pages freed
>>          kswapd0-629   [001] ....   293.161282: zs_compact: class  74: 20 objects scanned, 15 pages freed
>>          kswapd0-629   [001] ....   293.161306: zs_compact: class  71: 40 objects scanned, 20 pages freed
>>          kswapd0-629   [001] ....   293.161313: zs_compact: class  67: 8 objects scanned, 6 pages freed
>> ...
>>          kswapd0-629   [001] ....   293.161454: zs_compact: class   0: 0 objects scanned, 0 pages freed
>>          kswapd0-629   [001] ....   293.161455: zs_compact_end: pool zram0: 301 pages compacted
>> ----
>>
>> Also this patch changes trace_zsmalloc_compact_start[end] to
>> trace_zs_compact_start[end] to keep function naming consistent
>> with others in zsmalloc.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ----
>> v3:
>>     add per-class compact trace event - Minchan
>>
>>     I put this patch from 1/8 to 8/8, since this patch depends on below patch:
>>        mm/zsmalloc: use obj_index to keep consistent with others
>>        mm/zsmalloc: take obj index back from find_alloced_obj
>>
>
> Thanks for looking into this, Ganesh!
>
> Small change I want is to see the number of migrated object rather than
> the number of scanning object.
>
> If you don't mind, could you resend it with below?

I will resend a patch.

Thanks.

>
> Thanks.
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 3a1315e54057..166232a0aed6 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1774,7 +1774,7 @@ struct zs_compact_control {
>          * in the subpage. */
>         int obj_idx;
>
> -       unsigned long nr_scanned_obj;
> +       unsigned long nr_migrated_obj;
>         unsigned long nr_freed_pages;
>  };
>
> @@ -1809,6 +1809,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>                 free_obj = obj_malloc(class, get_zspage(d_page), handle);
>                 zs_object_copy(class, free_obj, used_obj);
>                 obj_idx++;
> +               cc->nr_migrated_obj++;
>                 /*
>                  * record_obj updates handle's value to free_obj and it will
>                  * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
> @@ -1821,8 +1822,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>                 obj_free(class, used_obj);
>         }
>
> -       cc->nr_scanned_obj += obj_idx - cc->obj_idx;
> -
>         /* Remember last position in this iteration */
>         cc->s_page = s_page;
>         cc->obj_idx = obj_idx;
> @@ -2270,7 +2269,7 @@ static unsigned long zs_can_compact(struct size_class *class)
>  static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  {
>         struct zs_compact_control cc = {
> -               .nr_scanned_obj = 0,
> +               .nr_migrated_obj = 0,
>                 .nr_freed_pages = 0,
>         };
>         struct zspage *src_zspage;
> @@ -2317,7 +2316,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>         spin_unlock(&class->lock);
>
>         pool->stats.pages_compacted += cc.nr_freed_pages;
> -       trace_zs_compact(class->index, cc.nr_scanned_obj, cc.nr_freed_pages);
> +       trace_zs_compact(class->index, cc.nr_migrated_obj, cc.nr_freed_pages);
>  }
>
>  unsigned long zs_compact(struct zs_pool *pool)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

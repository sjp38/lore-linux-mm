Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 451A86B0034
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 19:43:26 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id b45so3930402eek.1
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 16:43:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52092FB5.3060300@intel.com>
References: <1376322661-20917-1-git-send-email-haojian.zhuang@gmail.com>
	<52092FB5.3060300@intel.com>
Date: Tue, 13 Aug 2013 07:43:24 +0800
Message-ID: <CAN1soZxZyG4t=4M1pVZGMnR3twThsBKezx5dKy7uw68BwLRR-w@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: decrease cma pages from nr_reclaimed
From: Haojian Zhuang <haojian.zhuang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de

On Tue, Aug 13, 2013 at 2:55 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 08/12/2013 08:51 AM, Haojian Zhuang wrote:
>> @@ -987,6 +991,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>                                        * leave it off the LRU).
>>                                        */
>>                                       nr_reclaimed++;
>> +#ifdef CONFIG_CMA
>> +                                     if (get_pageblock_migratetype(page) ==
>> +                                             MIGRATE_CMA)
>> +                                             nr_reclaimed_cma++;
>> +#endif
>>                                       continue;
>>                               }
>>                       }
>
> Throwing four #ifdefs like that in to any is pretty mean.  Doing it to
> shrink_page_list() is just cruel. :)
>
> Can you think of a way to do this without so many explicit #ifdefs in a
> .c file?

OK. I'll use IS_ENABLED() instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

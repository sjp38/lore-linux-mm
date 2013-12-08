Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB3C6B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 22:11:07 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so3328613pbc.29
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 19:11:07 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id v7si3016039pbi.98.2013.12.07.19.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 19:11:06 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 08:41:02 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id C962D1258051
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 08:42:05 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB83Anht9765094
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 08:40:49 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB83AvEp016391
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 08:40:58 +0530
Date: Sun, 8 Dec 2013 11:10:56 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 5/6] sched/numa: make numamigrate_isolate_page static
Message-ID: <52a3e34a.0722440a.0571.ffff999dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386321136-27538-5-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386364795-hks9q1oj-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386364795-hks9q1oj-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Naoya,
On Fri, Dec 06, 2013 at 04:19:55PM -0500, Naoya Horiguchi wrote:
>On Fri, Dec 06, 2013 at 05:12:15PM +0800, Wanpeng Li wrote:
>> Make numamigrate_update_ratelimit static.
>
>Please change this function name, too :)

Indeed, the patch description should be "Make numamigrate_isolate_page
static".

Regards,
Wanpeng Li 

>
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
>Thanks,
>Naoya Horiguchi
>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/migrate.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index fdb70f7..7ad81e0 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1616,7 +1616,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
>>  	return rate_limited;
>>  }
>>  
>> -int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>> +static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>>  {
>>  	int page_lru;
>>  
>> -- 
>> 1.7.7.6
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

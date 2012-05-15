Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 81DB86B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:21:21 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 15 May 2012 05:21:20 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1247038C8059
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:21:17 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4F9LHBt128546
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:21:17 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4F9LFmO011740
	for <linux-mm@kvack.org>; Tue, 15 May 2012 03:21:16 -0600
Date: Tue, 15 May 2012 17:21:13 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: dump PG_compound_lock page flag
Message-ID: <20120515092113.GB4887@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1336991213-9149-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120514205134.GD1406@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120514205134.GD1406@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

>> The array pageflag_names[] is doing the conversion from page flag
>> into the corresponding names so that the meaingful string again
>> the corresponding page flag can be printed. The mechniasm is used
>> while dumping the specified page frame. However, the array missed
>> PG_compound_lock. So PG_compound_lock page flag would be printed
>> as ditigal number instead of meaningful string.
>> 
>> The patch fixes that and print "compound_lock" for PG_compound_lock
>> page flag.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>
>Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
>This on top?
>
>---

Thanks for your time, Johannes. The check at compliling time looks good.

Thanks,
Gavin

>From: Johannes Weiner <hannes@cmpxchg.org>
>Subject: [patch] mm: page_alloc: catch out-of-date list of page flag names
>
>String tables with names of enum items are always prone to go out of
>sync with the enums themselves.  Ensure during compile time that the
>name table of page flags has the same size as the page flags enum.
>
>Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>---
> mm/page_alloc.c |    2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 9325913..65ae58d 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5986,6 +5986,8 @@ static void dump_page_flags(unsigned long flags)
> 	unsigned long mask;
> 	int i;
>
>+	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) - 1 != __NR_PAGEFLAGS);
>+
> 	printk(KERN_ALERT "page flags: %#lx(", flags);
>
> 	/* remove zone id */
>-- 
>1.7.10.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

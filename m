Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9945E828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:51:24 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id f206so213638291wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:51:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si23148591wmd.56.2016.01.11.05.51.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 05:51:23 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: remove unused struct zone *z variable
References: <1452239948-1012-1-git-send-email-kuleshovmail@gmail.com>
 <20160108232942.GB13046@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5693B347.7050905@suse.cz>
Date: Mon, 11 Jan 2016 14:51:03 +0100
MIME-Version: 1.0
In-Reply-To: <20160108232942.GB13046@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Kuleshov <kuleshovmail@gmail.com>, Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/09/2016 12:29 AM, Kirill A. Shutemov wrote:
> On Fri, Jan 08, 2016 at 01:59:08PM +0600, Alexander Kuleshov wrote:
>> This patch removes unused struct zone *z variable which is
>> appeared in 86051ca5eaf5 (mm: fix usemap initialization)
> 
> I guess it's a fix for 1e8ce83cd17f (mm: meminit: move page initialization
> into a separate function).

Yeah but it's not a bug, so a tag like that would be just noise.

>> 
>> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>> ---
>>  mm/page_alloc.c | 2 --
>>  1 file changed, 2 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 9d666df..9bde098 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4471,13 +4471,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  	pg_data_t *pgdat = NODE_DATA(nid);
>>  	unsigned long end_pfn = start_pfn + size;
>>  	unsigned long pfn;
>> -	struct zone *z;
>>  	unsigned long nr_initialised = 0;
>>  
>>  	if (highest_memmap_pfn < end_pfn - 1)
>>  		highest_memmap_pfn = end_pfn - 1;
>>  
>> -	z = &pgdat->node_zones[zone];
>>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>>  		/*
>>  		 * There can be holes in boot-time mem_map[]s
>> -- 
>> 2.6.2.485.g1bc8fea
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

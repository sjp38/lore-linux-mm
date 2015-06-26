Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 138306B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:26:48 -0400 (EDT)
Received: by wgck11 with SMTP id k11so86076584wgc.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 04:26:47 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id eo2si57942489wjd.180.2015.06.26.04.26.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 04:26:46 -0700 (PDT)
Message-ID: <558D368F.8030900@huawei.com>
Date: Fri, 26 Jun 2015 19:25:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix set pageblock migratetype when boot
References: <558D24C1.5020901@huawei.com> <20150626110424.GI26927@suse.de>
In-Reply-To: <20150626110424.GI26927@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, David Rientjes <rientjes@google.com>, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/26 19:04, Mel Gorman wrote:

> On Fri, Jun 26, 2015 at 06:09:05PM +0800, Xishi Qiu wrote:
>> memmap_init_zone()
>> 	...
>> 	if ((z->zone_start_pfn <= pfn)
>> 	    && (pfn < zone_end_pfn(z))
>> 	    && !(pfn & (pageblock_nr_pages - 1)))
>> 		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>> 	...
>>
>> If the pfn does not align to pageblock, it will not init the migratetype.
> 
> What important impact does that have? It should leave a partial pageblock
> as MIGRATE_UNMOVABLE which is fine by me.
> 

Hi Mel,

The impact is less, it's OK to ignore it.

Thanks,
Xishi Qiu

>> So call it for every page, it will takes more time, but it doesn't matter, 
>> this function will be called only in boot or hotadd memory.
>>
> 
> It's a lot of additional overhead to add to memory initialisation. It
> would need to be for an excellent reason with no alternative solution.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

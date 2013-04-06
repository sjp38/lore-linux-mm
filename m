Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0C9C46B01AE
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:45:56 -0400 (EDT)
Received: by mail-da0-f49.google.com with SMTP id t11so1951892daj.22
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:45:56 -0700 (PDT)
Message-ID: <51603516.4040002@gmail.com>
Date: Sat, 06 Apr 2013 22:45:42 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4, part3 08/15] mm: fix some trivial typos in comments
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com> <1365256509-29024-9-git-send-email-jiang.liu@huawei.com> <516032EC.9080905@cogentembedded.com>
In-Reply-To: <516032EC.9080905@cogentembedded.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 04/06/2013 10:36 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 06-04-2013 17:55, Jiang Liu wrote:
> 
>> Fix some trivial typos in comments.
> 
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Cc: Wen Congyang <wency@cn.fujitsu.com>
>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>> Cc: Jiang Liu <jiang.liu@huawei.com>
>> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
> [...]
> 
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 57decb2..a5b8fde 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -309,7 +309,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
>>       /* can't move pfns which are higher than @z2 */
>>       if (end_pfn > zone_end_pfn(z2))
>>           goto out_fail;
>> -    /* the move out part mast at the left most of @z2 */
>> +    /* the move out part must at the left most of @z2 */
> 
>    Maybe "must be"?
Good catch!

> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6bd697c..c3c3eda 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2863,7 +2863,7 @@ EXPORT_SYMBOL(free_pages_exact);
>>    * nr_free_zone_pages() counts the number of counts pages which are beyond the
>>    * high watermark within all zones at or below a given zone index.  For each
>>    * zone, the number of pages is calculated as:
>> - *     present_pages - high_pages
>> + *     managed_pages - high_pages
> 
>    I'm not sure it's that trivial.
We just changes the comments to follow the code, so mark it as "trivial".

Regards!
Gerry

> 
> WBR, Sergei
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

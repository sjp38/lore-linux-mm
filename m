Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8419E6B002E
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:57:54 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p187so114554691wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 07:57:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 199si44078306wmu.115.2015.12.22.07.57.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 07:57:53 -0800 (PST)
Subject: Re: [PATCH] mm: make sure isolate_lru_page() is never called for tail
 page
References: <1450276170-140679-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151216144749.GB23092@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <567972FF.4090408@suse.cz>
Date: Tue, 22 Dec 2015 16:57:51 +0100
MIME-Version: 1.0
In-Reply-To: <20151216144749.GB23092@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 12/16/2015 03:47 PM, Michal Hocko wrote:
> On Wed 16-12-15 16:29:30, Kirill A. Shutemov wrote:
>> The VM_BUG_ON_PAGE() would catch such cases if any still exists.
>
> Thanks, this better than a silent breakage.
>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>
>> ---
>>   mm/vmscan.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 964390906167..05dd182f04fd 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1436,6 +1436,7 @@ int isolate_lru_page(struct page *page)
>>   	int ret = -EBUSY;
>>
>>   	VM_BUG_ON_PAGE(!page_count(page), page);
>> +	VM_BUG_ON_PAGE(PageTail(page), page);
>>
>>   	if (PageLRU(page)) {
>>   		struct zone *zone = page_zone(page);
>> --
>> 2.6.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

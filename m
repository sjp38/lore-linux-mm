Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D2F608D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:20:29 -0400 (EDT)
Message-ID: <4D8B4514.9050904@redhat.com>
Date: Thu, 24 Mar 2011 09:20:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: + ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages.patch
 added to -mm tree
References: <201103012341.p21Nf64e006469@imap1.linux-foundation.org> <20110324125316.GA2310@cmpxchg.org>
In-Reply-To: <20110324125316.GA2310@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, nai.xia@gmail.com, aarcange@redhat.com, chrisw@sous-sol.org, hugh.dickins@tiscali.co.uk, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/24/2011 08:53 AM, Johannes Weiner wrote:
> On Tue, Mar 01, 2011 at 03:41:06PM -0800, akpm@linux-foundation.org wrote:
>> diff -puN include/linux/mmzone.h~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages include/linux/mmzone.h
>> --- a/include/linux/mmzone.h~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages
>> +++ a/include/linux/mmzone.h
>> @@ -115,6 +115,9 @@ enum zone_stat_item {
>>   	NUMA_OTHER,		/* allocation from other node */
>>   #endif
>>   	NR_ANON_TRANSPARENT_HUGEPAGES,
>> +#ifdef CONFIG_KSM
>> +	NR_KSM_PAGES_SHARING,
>> +#endif
>>   	NR_VM_ZONE_STAT_ITEMS };
>
> This adds a zone stat item without a corresponding entry in
> vm_stat_text.  As a result, all vm event entries in /proc/vmstat show
> the value of the respective previous counter.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id ACBE46B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 11:37:09 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r11so298430pdi.21
        for <linux-mm@kvack.org>; Fri, 29 Mar 2013 08:37:08 -0700 (PDT)
Message-ID: <5155B517.3040501@gmail.com>
Date: Fri, 29 Mar 2013 23:36:55 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3, part4 38/39] mm/hotplug: prepare for removing num_physpages
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com> <1364313298-17336-39-git-send-email-jiang.liu@huawei.com> <20130329111856.GA3824@merkur.ravnborg.org>
In-Reply-To: <20130329111856.GA3824@merkur.ravnborg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On 03/29/2013 07:18 PM, Sam Ravnborg wrote:
> On Tue, Mar 26, 2013 at 11:54:57PM +0800, Jiang Liu wrote:
>> Prepare for removing num_physpages.
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Cc: Wen Congyang <wency@cn.fujitsu.com>
>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>> Hi all,
>> 	Sorry for my mistake that my previous patch series has been screwed up.
>> So I regenerate a third version and also set up a git tree at:
>> 	git://github.com/jiangliu/linux.git mem_init
>> 	Any help to review and test are welcomed!
>>
>> 	Regards!
>> 	Gerry
>> ---
>>  mm/memory_hotplug.c |    4 ----
>>  1 file changed, 4 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 97454b3..9b1b494 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -751,10 +751,6 @@ EXPORT_SYMBOL_GPL(restore_online_page_callback);
>>  
>>  void __online_page_set_limits(struct page *page)
>>  {
>> -	unsigned long pfn = page_to_pfn(page);
>> -
>> -	if (pfn >= num_physpages)
>> -		num_physpages = pfn + 1;
>>  }
>>  EXPORT_SYMBOL_GPL(__online_page_set_limits);
> 
> How can this be correct?
> With this change __online_page_set_limits() is now a nop.
Hi Sam,
	We will eventually remove the global variable num_physpages in the last patch.
I kept the nop __online_page_set_limits() because I have a plan to use it to fix other
bugs in memory hotplug, otherwise it may be killed too.
	Regards!
	Gerry

> 
> 	Sam
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

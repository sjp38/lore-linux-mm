Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 0BC5B6B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 12:30:26 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id p8so270523dan.7
        for <linux-mm@kvack.org>; Fri, 29 Mar 2013 09:30:26 -0700 (PDT)
Message-ID: <5155C196.5020909@gmail.com>
Date: Sat, 30 Mar 2013 00:30:14 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3, part4 38/39] mm/hotplug: prepare for removing num_physpages
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com> <1364313298-17336-39-git-send-email-jiang.liu@huawei.com> <20130329111856.GA3824@merkur.ravnborg.org> <5155B517.3040501@gmail.com> <20130329161700.GA6201@merkur.ravnborg.org>
In-Reply-To: <20130329161700.GA6201@merkur.ravnborg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On 03/30/2013 12:17 AM, Sam Ravnborg wrote:
>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>> index 97454b3..9b1b494 100644
>>>> --- a/mm/memory_hotplug.c
>>>> +++ b/mm/memory_hotplug.c
>>>> @@ -751,10 +751,6 @@ EXPORT_SYMBOL_GPL(restore_online_page_callback);
>>>>  
>>>>  void __online_page_set_limits(struct page *page)
>>>>  {
>>>> -	unsigned long pfn = page_to_pfn(page);
>>>> -
>>>> -	if (pfn >= num_physpages)
>>>> -		num_physpages = pfn + 1;
>>>>  }
>>>>  EXPORT_SYMBOL_GPL(__online_page_set_limits);
>>>
>>> How can this be correct?
>>> With this change __online_page_set_limits() is now a nop.
>> Hi Sam,
>> 	We will eventually remove the global variable num_physpages in the last patch.
>> I kept the nop __online_page_set_limits() because I have a plan to use it to fix other
>> bugs in memory hotplug, otherwise it may be killed too.
> 
> The xen ballon driver uses __online_page_set_limits for memory
> hotplug - so this will break this driver afaics.
Hi Sam,
	I haven't gotten your point yet here. 
	Function __online_page_set_limits() was only used to update the global variable
num_physpages, and one of the goals of this patch set is to get rid of num_physpages.
So I think it won't break Xen balloon driver.
	Please refer to the patch here, which eventually kills num_physpages.
http://marc.info/?l=linux-mm&m=136431387813309&w=2

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

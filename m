Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA84xfln019831
	for <linux-mm@kvack.org>; Fri, 7 Nov 2008 21:59:41 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA850kcg149946
	for <linux-mm@kvack.org>; Fri, 7 Nov 2008 22:00:46 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA850GF4014294
	for <linux-mm@kvack.org>; Fri, 7 Nov 2008 22:00:17 -0700
Message-ID: <49151CFF.8060503@us.ibm.com>
Date: Fri, 07 Nov 2008 21:00:47 -0800
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.28-rc3 mem_cgroup panic
References: <1226096940.8805.4.camel@badari-desktop> <31630.10.75.179.62.1226111079.squirrel@webmail-b.css.fujitsu.com> <38971.10.75.179.62.1226112376.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <38971.10.75.179.62.1226112376.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@in.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> KAMEZAWA Hiroyuki said:
>   
>> Badari Pulavarty said:
>>     
>>> Hi Balbir,
>>>
>>> I was running memory remove/add tests in a continuous loop.
>>> I get following panic in mem_cgroup migration code.
>>>
>>> Is this a known issue ?
>>>
>>>       
>> No, this is new one. We don't see panic in cpuset based migration..so..
>> Maybe related to page_cgroup allocation/free code in memory hotplug
>> notifier.
>>
>> Thank you for report. I'll try this.
>>
>>     
> Hmm...at quick look...
>
> online/offline page_cgroup's calculation for "start" is buggy..
>
> -start = start_pfn & (PAGES_PER_SECTION - 1);
> +start = start_pfn & ~(PAGES_PER_SECTION - 1);
>
> I'm sorry I can't write patch today.
>
> Regards,
> -Kame
>
>   

Thanks for the fix. Tests are running fine now.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

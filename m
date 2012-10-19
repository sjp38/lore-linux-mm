Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AEE0F6B0044
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:29:28 -0400 (EDT)
Message-ID: <508102A8.1050605@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 15:35:04 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to
 acpi_memory_device_remove()
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com> <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com> <50727984.20401@cn.fujitsu.com> <CAHGf_=pCrx8AkL9eiSYVgwvT1v0SW2__P_DW-1Wwj_zskqcLXw@mail.gmail.com> <507E54AA.2080806@cn.fujitsu.com> <CAHGf_=o_Wu1kr56C=7XTjYRzL4egSyGJYd4+2RecVWzpeM427Q@mail.gmail.com> <507E75AA.2000605@cn.fujitsu.com> <CAHGf_=oNufcAQhxWtvq56qwF==+14+Cm7r9eiTGdY=B=ENwPQg@mail.gmail.com> <507E7FC2.8@cn.fujitsu.com> <507F5A78.7030500@jp.fujitsu.com>
In-Reply-To: <507F5A78.7030500@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

At 10/18/2012 09:25 AM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/10/17 18:52, Wen Congyang wrote:
>> At 10/17/2012 05:18 PM, KOSAKI Motohiro Wrote:
>>>>>>>> Hmm, it doesn't move the code. It just reuse the code in
>>>>>>>> acpi_memory_powerdown_device().
>>>>>>>
>>>>>>> Even if reuse or not reuse, you changed the behavior. If any changes
>>>>>>> has no good rational, you cannot get an ack.
>>>>>>
>>>>>> I don't understand this? IIRC, the behavior isn't changed.
>>>>>
>>>>> Heh, please explain why do you think so.
>>>>
>>>> We just introduce a function, and move codes from
>>>> acpi_memory_disable_device() to the new
>>>> function. We call the new function in acpi_memory_disable_device(),
>>>> so the function
>>>> acpi_memory_disable_device()'s behavior isn't changed.
>>>>
>>>> Maybe I don't understand what do you want to say.
>>>
>>> Ok, now you agreed you moved the code, yes? So then, you should
>>> explain why
>>> your code moving makes zero impact other acpi_memory_disable_device()
>>> caller.
>>
>> We just move the code, and don't change the
>> acpi_memory_disable_device()'s behavior.
>>
>> I look it the change again, and found some diffs:
>> 1. we treat !info->enabled as error, while it isn't a error without
>> this patch
>> 2. we remove memory info from the list, it is a bug fix because we
>> free the memory
>>     that stores memory info.(I have sent a patch to fix this bug, and
>> it is in akpm's tree now)
>>
>> I guess you mean 1 will change the behavior. In the last version, I
>> don't do it.
>> Ishimatsu changes this and I don't notify this.
>>
>> To Ishimatsu:
>>
>> Why do you change this?
> 
> Oops. If so, it's my mistake.
> Could you update it in next version?

OK

Thanks
Wen Congyang

> 
> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> Thanks
>> Wen Congyang
>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe
>>> linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

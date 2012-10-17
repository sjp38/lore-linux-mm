Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1AFCD6B005D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 05:19:13 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so8693400obc.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 02:19:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507E75AA.2000605@cn.fujitsu.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com>
 <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com>
 <50727984.20401@cn.fujitsu.com> <CAHGf_=pCrx8AkL9eiSYVgwvT1v0SW2__P_DW-1Wwj_zskqcLXw@mail.gmail.com>
 <507E54AA.2080806@cn.fujitsu.com> <CAHGf_=o_Wu1kr56C=7XTjYRzL4egSyGJYd4+2RecVWzpeM427Q@mail.gmail.com>
 <507E75AA.2000605@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 17 Oct 2012 05:18:51 -0400
Message-ID: <CAHGf_=oNufcAQhxWtvq56qwF==+14+Cm7r9eiTGdY=B=ENwPQg@mail.gmail.com>
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to acpi_memory_device_remove()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

>>>>> Hmm, it doesn't move the code. It just reuse the code in acpi_memory_powerdown_device().
>>>>
>>>> Even if reuse or not reuse, you changed the behavior. If any changes
>>>> has no good rational, you cannot get an ack.
>>>
>>> I don't understand this? IIRC, the behavior isn't changed.
>>
>> Heh, please explain why do you think so.
>
> We just introduce a function, and move codes from acpi_memory_disable_device() to the new
> function. We call the new function in acpi_memory_disable_device(), so the function
> acpi_memory_disable_device()'s behavior isn't changed.
>
> Maybe I don't understand what do you want to say.

Ok, now you agreed you moved the code, yes? So then, you should explain why
your code moving makes zero impact other acpi_memory_disable_device() caller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8857D6B005A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 11:35:11 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so3142075oag.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:35:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=rYgA=yAjcvziGbN0k48zTZn8+5XQJxoMwZ4wvrX6x4sA@mail.gmail.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com>
 <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com>
 <50727984.20401@cn.fujitsu.com> <CAHGf_=pCrx8AkL9eiSYVgwvT1v0SW2__P_DW-1Wwj_zskqcLXw@mail.gmail.com>
 <507E77D1.3030709@cn.fujitsu.com> <CAHGf_=rxGeb0RsgEFF2FRRfdX0wiE9cDyVaftsG3E8AgyzYi1g@mail.gmail.com>
 <508118A6.80804@cn.fujitsu.com> <CAHGf_=qfzEJ0VjeYkKFVtyew+wYM-rHS4nqmXU4t7HYGuv8k9w@mail.gmail.com>
 <5082305A.2050108@cn.fujitsu.com> <CAHGf_=rYgA=yAjcvziGbN0k48zTZn8+5XQJxoMwZ4wvrX6x4sA@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 22 Oct 2012 11:34:49 -0400
Message-ID: <CAHGf_=qK=mAAwor7iXxDtwTtW2Qhui_8GmtHGreMuFuQVGWAvQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to acpi_memory_device_remove()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

On Mon, Oct 22, 2012 at 11:11 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>> ??
>>> If resource was not allocated a driver, a driver doesn't need to
>>> deallocate it when
>>> error path. I haven't caught your point.
>>>
>>
>> REMOVAL_NORMAL can be in 2 cases:
>> 1. error path. If init call fails, we don't call it. We call this function
>>    only when something fails after init.
>> 2. unbind the device from the driver.
>>    If we don't offline and remove memory when unbinding the device from the driver,
>>    the device may be out of control. When we eject this driver, we don't offline and
>
> Memory never be out of control by driver unloading. It is controled
> from kernel core. It is an exception from regular linux driver model.

Ah, got it.
acpi_bus_hot_remove_device() evaluate PS3 before EJ0. Then
your first patch may cause memory lost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

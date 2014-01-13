Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id D585E6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:40:08 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so7975694qen.29
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:40:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id kb1si25204929qeb.113.2014.01.13.15.40.07
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 15:40:08 -0800 (PST)
Message-ID: <52D4793E.8070102@redhat.com>
Date: Mon, 13 Jan 2014 18:39:42 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user [v2]
References: <1389380698-19361-1-git-send-email-prarit@redhat.com> <1389380698-19361-4-git-send-email-prarit@redhat.com> <alpine.DEB.2.02.1401111624170.20677@be1.lrz> <52D32962.5050908@redhat.com> <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>
In-Reply-To: <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Bodo Eggert <7eggert@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, dyoung@redhat.com, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 01/13/2014 03:31 PM, KOSAKI Motohiro wrote:
> On Sun, Jan 12, 2014 at 6:46 PM, Prarit Bhargava <prarit@redhat.com> wrote:
>>
>>
>> On 01/11/2014 11:35 AM, 7eggert@gmx.de wrote:
>>>
>>>
>>> On Fri, 10 Jan 2014, Prarit Bhargava wrote:
>>>
>>>> kdump uses memmap=exactmap and mem=X values to configure the memory
>>>> mapping for the kdump kernel.  If memory is hotadded during the boot of
>>>> the kdump kernel it is possible that the page tables for the new memory
>>>> cause the kdump kernel to run out of memory.
>>>>
>>>> Since the user has specified a specific mapping ACPI Memory Hotplug should be
>>>> disabled in this case.
>>>
>>> I'll ask just in case: Is it possible to want memory hotplug in spite of
>>> using memmap=exactmap or mem=X?
>>
>> Good question -- I can't think of a case.  When a user specifies "memmap" or
>> "mem" IMO they are asking for a very specific memory configuration.  Having
>> extra memory added above what the user has specified seems to defeat the purpose
>> of "memmap" and "mem".
> 
> May be yes, may be no.
> 
> They are often used for a wrokaround to avoid broken firmware issue.
> If we have no way
> to explicitly enable hotplug. We will lose a workaround.
> 
> Perhaps, there is no matter. Today, memory hotplug is only used on
> high-end machine
> and their firmware is carefully developped and don't have a serious
> issue almostly. Though.

Oof -- sorry Kosaki :(  I didn't see this until just now (and your subsequent
ACK on the updated patch).

I just remembered that we did have a processor vendor's whitebox that would not
boot unless we specified a specific memmap and we did specify memmap=exactmap to
boot the system correctly and the system had hotplug memory.

So it means that I should not key off of "memmap=exactmap".

I will self-NAK the updated patch and submit a new one.

P.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

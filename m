Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id AE6D76B0036
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:05:31 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id nc12so1447433qeb.30
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 03:05:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t8si235329qeu.56.2014.01.14.03.05.30
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 03:05:31 -0800 (PST)
Message-ID: <52D519EB.3040709@redhat.com>
Date: Tue, 14 Jan 2014 06:05:15 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, acpi memory hotplug, add parameter to disable memory
 hotplug
References: <1389650161-13292-1-git-send-email-prarit@redhat.com>	 <CAHGf_=pX303E6VAhL+gApSQ1OsEQHqTuCN8ZSdD3E54YAcFQKA@mail.gmail.com>	 <52D47999.5080905@redhat.com> <52D48EC4.5070400@jp.fujitsu.com> <1389663689.1792.268.camel@misato.fc.hp.com>
In-Reply-To: <1389663689.1792.268.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 01/13/2014 08:41 PM, Toshi Kani wrote:
> On Tue, 2014-01-14 at 10:11 +0900, Yasuaki Ishimatsu wrote:
>  :
>>>> I think we need a knob manually enable mem-hotplug when specify memmap. But
>>>> it is another story.
>>>>
>>>> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>
>>> As mentioned, self-NAK.  I have seen a system that I needed to specify
>>> memmap=exactmap & had hotplug memory.  I will only keep the acpi_no_memhotplug
>>> option in the next version of the patch.
>>
>>
>> Your following first patch is simply and makes sense.
>>
>> http://marc.info/?l=linux-acpi&m=138922019607796&w=2
>>
> 
> In this option, it also requires changing kexec-tools to specify the new
> option for kdump.  It won't be simpler.

It will be simpler for the kernel and those of us who have to debug busted e820
maps ;)

Unfortunately I may not be able to give you the automatic disable.  I did
contemplate adding a !is_kdump_kernel() to the ACPI memory hotplug init call,
but it seems like that is unacceptable as well.

P.

> 
> Thanks,
> -Toshi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

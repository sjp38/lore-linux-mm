Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C82706B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 21:44:51 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so2886505pdj.29
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:44:51 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id nu8si17407954pbb.342.2014.01.13.18.44.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 18:44:50 -0800 (PST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 492A43EE1D9
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:44:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37CA345DE54
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:44:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DDC845DE4E
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:44:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A8FD1DB8032
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:44:48 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B445D1DB803E
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:44:47 +0900 (JST)
Message-ID: <52D4A469.9090100@jp.fujitsu.com>
Date: Tue, 14 Jan 2014 11:43:53 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, acpi memory hotplug, add parameter to disable memory
 hotplug
References: <1389650161-13292-1-git-send-email-prarit@redhat.com>  <CAHGf_=pX303E6VAhL+gApSQ1OsEQHqTuCN8ZSdD3E54YAcFQKA@mail.gmail.com>  <52D47999.5080905@redhat.com> <52D48EC4.5070400@jp.fujitsu.com> <1389663689.1792.268.camel@misato.fc.hp.com>
In-Reply-To: <1389663689.1792.268.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Prarit Bhargava <prarit@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

(2014/01/14 10:41), Toshi Kani wrote:
> On Tue, 2014-01-14 at 10:11 +0900, Yasuaki Ishimatsu wrote:
>   :
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

Hmm.
I use memm= boot option and hotplug memory for memory hot-remove.
At least, the patch cannot be accepted.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

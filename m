Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f180.google.com (mail-gg0-f180.google.com [209.85.161.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE016B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 19:54:18 -0500 (EST)
Received: by mail-gg0-f180.google.com with SMTP id q3so1678921gge.39
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 16:54:18 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id r49si22676712yho.292.2014.01.13.16.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jan 2014 16:54:17 -0800 (PST)
Message-ID: <52D48A9D.7000003@zytor.com>
Date: Mon, 13 Jan 2014 16:53:49 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user [v2]
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>	 <1389380698-19361-4-git-send-email-prarit@redhat.com>	 <alpine.DEB.2.02.1401111624170.20677@be1.lrz> <52D32962.5050908@redhat.com>	 <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>	 <52D4793E.8070102@redhat.com> <1389659632.1792.247.camel@misato.fc.hp.com>
In-Reply-To: <1389659632.1792.247.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Prarit Bhargava <prarit@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bodo Eggert <7eggert@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, dyoung@redhat.com, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/13/2014 04:33 PM, Toshi Kani wrote:
> 
> I do not think it makes sense.  You needed memmap=exactmap as a
> workaround because the kernel did not boot with the firmware's memory
> info.  So, it's broken, and you requested the kernel to ignore the
> firmware info.
> 
> Why do you think memory hotplug needs to be supported under such
> condition, which has to use the broken firmware info?
> 

Even more than memory hotplug: what do we do with NUMA?  Since we have
already told the kernel "the firmware is bogus" it would seem that any
NUMA optimizations would be a bit ... cantankerous at best, no?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

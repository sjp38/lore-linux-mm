Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 754EE6B0035
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 02:24:28 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so548226pde.27
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 23:24:28 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id hb3si60538012pac.7.2013.12.05.23.24.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 23:24:27 -0800 (PST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 45C0E3EE1A7
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:24:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3602D45DE4D
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:24:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 187DF45DE4E
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:24:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08C2B1DB803F
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:24:25 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4C761DB802C
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:24:24 +0900 (JST)
Message-ID: <52A17B83.8060601@jp.fujitsu.com>
Date: Fri, 6 Dec 2013 16:23:47 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, x86: Skip NUMA_NO_NODE while parsing SLIT
References: <1386191348-4696-1-git-send-email-toshi.kani@hp.com>  <52A054A0.6060108@jp.fujitsu.com> <1386256309.1791.253.camel@misato.fc.hp.com>
In-Reply-To: <1386256309.1791.253.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

(2013/12/06 0:11), Toshi Kani wrote:
> On Thu, 2013-12-05 at 19:25 +0900, Yasuaki Ishimatsu wrote:
>> (2013/12/05 6:09), Toshi Kani wrote:
>>> When ACPI SLIT table has an I/O locality (i.e. a locality unique
>>> to an I/O device), numa_set_distance() emits the warning message
>>> below.
>>>
>>>    NUMA: Warning: node ids are out of bound, from=-1 to=-1 distance=10
>>>
>>> acpi_numa_slit_init() calls numa_set_distance() with pxm_to_node(),
>>> which assumes that all localities have been parsed with SRAT previously.
>>> SRAT does not list I/O localities, where as SLIT lists all localities
>>
>>> including I/Os.  Hence, pxm_to_node() returns NUMA_NO_NODE (-1) for
>>> an I/O locality.  I/O localities are not supported and are ignored
>>> today, but emitting such warning message leads unnecessary confusion.
>>
>> In this case, the warning message should not be shown. But if SLIT table
>> is really broken, the message should be shown. Your patch seems to not care
>> for second case.
>
> In the second case, I assume you are worrying about the case of SLIT
> table with bad locality numbers.  Since SLIT is a matrix of the number
> of localities, it is only possible by making the table bigger than
> necessary.  Such excessive localities are safe to ignore (as they are
> ignored today) and regular users have nothing to concern about them.
> The warning message in this case may be helpful for platform vendors to
> test their firmware, but they have plenty of other methods to verify
> their SLIT table.

I understood it. So,

Reviewed-by : Yasuaki Ishimatsu

Thanks,
Yasuaki Ishimatsu


> Thanks,
> -Toshi
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

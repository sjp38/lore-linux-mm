Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id F03DA6B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 18:47:04 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so814818qcy.25
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 15:47:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g2si5470477qag.45.2014.01.12.15.47.02
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 15:47:02 -0800 (PST)
Message-ID: <52D32962.5050908@redhat.com>
Date: Sun, 12 Jan 2014 18:46:42 -0500
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user [v2]
References: <1389380698-19361-1-git-send-email-prarit@redhat.com> <1389380698-19361-4-git-send-email-prarit@redhat.com> <alpine.DEB.2.02.1401111624170.20677@be1.lrz>
In-Reply-To: <alpine.DEB.2.02.1401111624170.20677@be1.lrz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 7eggert@gmx.de
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, kosaki.motohiro@gmail.com, dyoung@redhat.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org



On 01/11/2014 11:35 AM, 7eggert@gmx.de wrote:
> 
> 
> On Fri, 10 Jan 2014, Prarit Bhargava wrote:
> 
>> kdump uses memmap=exactmap and mem=X values to configure the memory
>> mapping for the kdump kernel.  If memory is hotadded during the boot of
>> the kdump kernel it is possible that the page tables for the new memory
>> cause the kdump kernel to run out of memory.
>>
>> Since the user has specified a specific mapping ACPI Memory Hotplug should be
>> disabled in this case.
> 
> I'll ask just in case: Is it possible to want memory hotplug in spite of 
> using memmap=exactmap or mem=X?

Good question -- I can't think of a case.  When a user specifies "memmap" or
"mem" IMO they are asking for a very specific memory configuration.  Having
extra memory added above what the user has specified seems to defeat the purpose
of "memmap" and "mem".

P.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

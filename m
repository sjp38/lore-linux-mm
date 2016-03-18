Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F101828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:36:21 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id p65so62357089wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 03:36:21 -0700 (PDT)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id c19si15362390wjr.29.2016.03.18.03.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 03:36:17 -0700 (PDT)
Date: Fri, 18 Mar 2016 11:34:03 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v6 0/5] Make cpuid <-> nodeid mapping persistent
In-Reply-To: <CAJZ5v0jFpQ75sKv6LS2z6h0h0YotgmtTbhjByuBgJL_JPtX=NQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1603181133310.3978@nanos>
References: <cover.1458177577.git.zhugh.fnst@cn.fujitsu.com> <CAJZ5v0jFpQ75sKv6LS2z6h0h0YotgmtTbhjByuBgJL_JPtX=NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, cl@linux.com, Tejun Heo <tj@kernel.org>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, Len Brown <lenb@kernel.org>, chen.tang@easystack.cn, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 17 Mar 2016, Rafael J. Wysocki wrote:
> >  arch/ia64/kernel/acpi.c       |   2 +-
> >  arch/x86/include/asm/mpspec.h |   1 +
> >  arch/x86/kernel/acpi/boot.c   |   8 ++-
> >  arch/x86/kernel/apic/apic.c   |  85 +++++++++++++++++++++++++----
> >  arch/x86/mm/numa.c            |  27 +++++-----
> >  drivers/acpi/acpi_processor.c |   5 +-
> >  drivers/acpi/bus.c            |   3 ++
> >  drivers/acpi/processor_core.c | 122 ++++++++++++++++++++++++++++++++++--------
> >  include/linux/acpi.h          |   6 +++
> >  9 files changed, 208 insertions(+), 51 deletions(-)
> >
> 
> OK
> 
> Since I know that there is demand for these changes, I'll queue them
> up early for 4.7 if there are no comments from the x86 maintainers
> till then.

Acked-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

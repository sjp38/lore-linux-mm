Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6303F6B0039
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:40:46 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id hk11so385836igb.0
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:40:46 -0800 (PST)
Received: from g4t0015.houston.hp.com (g4t0015.houston.hp.com. [15.201.24.18])
        by mx.google.com with ESMTPS id h18si4924798igt.26.2014.01.10.13.40.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 13:40:45 -0800 (PST)
Message-ID: <1389389688.1792.174.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory
 mapping is specified by user [v2]
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 10 Jan 2014 14:34:48 -0700
In-Reply-To: <1389380698-19361-4-git-send-email-prarit@redhat.com>
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>
	 <1389380698-19361-4-git-send-email-prarit@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, kosaki.motohiro@gmail.com, dyoung@redhat.com, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Fri, 2014-01-10 at 14:04 -0500, Prarit Bhargava wrote:
 :
>  arch/x86/kernel/e820.c         |   10 +++++++++-
>  drivers/acpi/acpi_memhotplug.c |    7 ++++++-
>  include/linux/memory_hotplug.h |    3 +++
>  3 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index 174da5f..747f36a 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -20,6 +20,7 @@
>  #include <linux/firmware-map.h>
>  #include <linux/memblock.h>
>  #include <linux/sort.h>
> +#include <linux/memory_hotplug.h>
>  
>  #include <asm/e820.h>
>  #include <asm/proto.h>
> @@ -834,6 +835,8 @@ static int __init parse_memopt(char *p)
>  		return -EINVAL;
>  	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
>  
> +	set_acpi_no_memhotplug();
> +

It won't build when CONFIG_ACPI_HOTPLUG_MEMORY is not defined.

Thanks,
-Toshi




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

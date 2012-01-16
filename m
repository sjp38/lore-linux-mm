Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 17CAF6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 18:50:32 -0500 (EST)
Received: by ghbg19 with SMTP id g19so2494942ghb.14
        for <linux-mm@kvack.org>; Mon, 16 Jan 2012 15:50:31 -0800 (PST)
Date: Mon, 16 Jan 2012 15:50:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] config menu: move ZONE_DMA under a menu
In-Reply-To: <4F14811E.6090107@xenotime.net>
Message-ID: <alpine.DEB.2.00.1201161548580.16270@chino.kir.corp.google.com>
References: <4F14811E.6090107@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org

On Mon, 16 Jan 2012, Randy Dunlap wrote:

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Move the ZONE_DMA kconfig symbol under a menu item instead
> of having it listed before everything else in
> "make {xconfig | gconfig | nconfig | menuconfig}".
> 
> This drops the first line of the top-level kernel config menu
> (in 3.2) below and moves it under "Processor type and features".
> 
>           [*] DMA memory allocation support
>               General setup  --->
>           [*] Enable loadable module support  --->
>           [*] Enable the block layer  --->
>               Processor type and features  --->
>               Power management and ACPI options  --->
>               Bus options (PCI etc.)  --->
>               Executable file formats / Emulations  --->
> 
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 552066B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 12:53:50 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r88so9271747pfi.23
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 09:53:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f28si5882421pgn.758.2017.12.08.09.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 09:53:48 -0800 (PST)
Date: Fri, 8 Dec 2017 11:53:45 -0600
From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 4/9] pci: remove unneeded kallsyms include
Message-ID: <20171208175345.GA12367@bhelgaas-glaptop.roam.corp.google.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <20171208025616.16267-5-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208025616.16267-5-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Dec 08, 2017 at 11:56:11AM +0900, Sergey Senozhatsky wrote:
> The file was converted from print_fn_descriptor_symbol()
> to %pF some time ago (c9bbb4abb658da "PCI: use %pF instead
> of print_fn_descriptor_symbol() in quirks.c"). kallsyms does
> not seem to be needed anymore.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>

Applied to pci/misc for v4.16, thanks for cleaning this up!

I *assume* there's no ordering dependency like the one you mentioned
for sched/printk.  If there is, let me know, and I'll move this to
for-linus to get it in v4.15.

> ---
>  drivers/pci/quirks.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index 10684b17d0bd..fd49b976973f 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -19,7 +19,6 @@
>  #include <linux/init.h>
>  #include <linux/delay.h>
>  #include <linux/acpi.h>
> -#include <linux/kallsyms.h>
>  #include <linux/dmi.h>
>  #include <linux/pci-aspm.h>
>  #include <linux/ioport.h>
> -- 
> 2.15.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

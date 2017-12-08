Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8831F6B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:02:24 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id s9so4841410oie.2
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:02:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u184sor2750148oie.163.2017.12.08.06.02.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 06:02:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171208025616.16267-6-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com> <20171208025616.16267-6-sergey.senozhatsky@gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Fri, 8 Dec 2017 15:02:22 +0100
Message-ID: <CAJZ5v0hQ+QyJZ_bw9AGaSByvckpK5MeU=jkuy-MYg4Qdzoxrrw@mail.gmail.com>
Subject: Re: [PATCH 5/9] pnp: remove unneeded kallsyms include
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Dec 8, 2017 at 3:56 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> The file was converted from print_fn_descriptor_symbol()
> to %pF some time ago (2e532d68a2b3e2aa {pci,pnp} quirks.c:
> don't use deprecated print_fn_descriptor_symbol()). kallsyms
> does not seem to be needed anymore.
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  drivers/pnp/quirks.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/pnp/quirks.c b/drivers/pnp/quirks.c
> index f054cdddfef8..803666ae3635 100644
> --- a/drivers/pnp/quirks.c
> +++ b/drivers/pnp/quirks.c
> @@ -21,7 +21,6 @@
>  #include <linux/slab.h>
>  #include <linux/pnp.h>
>  #include <linux/io.h>
> -#include <linux/kallsyms.h>
>  #include "base.h"
>
>  static void quirk_awe32_add_ports(struct pnp_dev *dev,
> --

Do you want me to apply this or do you want to route it differently?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

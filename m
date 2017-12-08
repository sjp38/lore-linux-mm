Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 779206B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:48:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 3so8977656pfo.1
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:48:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z65sor2281991pgd.219.2017.12.08.06.48.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 06:48:47 -0800 (PST)
Date: Fri, 8 Dec 2017 23:48:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 3/9] power: remove unneeded kallsyms include
Message-ID: <20171208144844.GA489@tigerII.localdomain>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <20171208025616.16267-4-sergey.senozhatsky@gmail.com>
 <CAJZ5v0g1CBhKTYi=CzYPcBXdH=yZ3iJcKzZ6TaftNWoq+X5wnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0g1CBhKTYi=CzYPcBXdH=yZ3iJcKzZ6TaftNWoq+X5wnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (12/08/17 15:01), Rafael J. Wysocki wrote:
> On Fri, Dec 8, 2017 at 3:56 AM, Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
> > The file was converted from print_fn_descriptor_symbol()
> > to %pF some time ago (c80cfb0406c01bb "vsprintf: use new
> > vsprintf symbolic function pointer format"). kallsyms does
> > not seem to be needed anymore.
> >
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Rafael Wysocki <rjw@rjwysocki.net>
> > Cc: Len Brown <len.brown@intel.com>
> > ---
> >  drivers/base/power/main.c | 1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
> > index 5bc2cf1f812c..e2539d8423f7 100644
> > --- a/drivers/base/power/main.c
> > +++ b/drivers/base/power/main.c
> > @@ -18,7 +18,6 @@
> >   */
> >
> >  #include <linux/device.h>
> > -#include <linux/kallsyms.h>
> >  #include <linux/export.h>
> >  #include <linux/mutex.h>
> >  #include <linux/pm.h>
> > --
> 
> Do you want me to apply this or do you want to route it differently?

Hello Rafael,

don't mind if you'll pick it up.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

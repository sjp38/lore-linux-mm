Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4A96B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 13:05:06 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id t13so3381483lfe.2
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 10:05:06 -0800 (PST)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id y71si810868lfk.329.2017.12.17.10.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Dec 2017 10:05:04 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 3/9] power: remove unneeded kallsyms include
Date: Sun, 17 Dec 2017 19:04:16 +0100
Message-ID: <4033333.ijW7uRe5gx@aspire.rjw.lan>
In-Reply-To: <20171208144844.GA489@tigerII.localdomain>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com> <CAJZ5v0g1CBhKTYi=CzYPcBXdH=yZ3iJcKzZ6TaftNWoq+X5wnQ@mail.gmail.com> <20171208144844.GA489@tigerII.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Friday, December 8, 2017 3:48:44 PM CET Sergey Senozhatsky wrote:
> On (12/08/17 15:01), Rafael J. Wysocki wrote:
> > On Fri, Dec 8, 2017 at 3:56 AM, Sergey Senozhatsky
> > <sergey.senozhatsky.work@gmail.com> wrote:
> > > The file was converted from print_fn_descriptor_symbol()
> > > to %pF some time ago (c80cfb0406c01bb "vsprintf: use new
> > > vsprintf symbolic function pointer format"). kallsyms does
> > > not seem to be needed anymore.
> > >
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Cc: Rafael Wysocki <rjw@rjwysocki.net>
> > > Cc: Len Brown <len.brown@intel.com>
> > > ---
> > >  drivers/base/power/main.c | 1 -
> > >  1 file changed, 1 deletion(-)
> > >
> > > diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
> > > index 5bc2cf1f812c..e2539d8423f7 100644
> > > --- a/drivers/base/power/main.c
> > > +++ b/drivers/base/power/main.c
> > > @@ -18,7 +18,6 @@
> > >   */
> > >
> > >  #include <linux/device.h>
> > > -#include <linux/kallsyms.h>
> > >  #include <linux/export.h>
> > >  #include <linux/mutex.h>
> > >  #include <linux/pm.h>
> > > --
> > 
> > Do you want me to apply this or do you want to route it differently?
> 
> Hello Rafael,
> 
> don't mind if you'll pick it up.

OK, applied now.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

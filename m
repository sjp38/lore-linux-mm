Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6FA6B0038
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 13:05:26 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id u207so2432302lff.4
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 10:05:26 -0800 (PST)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id c74si3923067lfc.168.2017.12.17.10.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Dec 2017 10:05:25 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 5/9] pnp: remove unneeded kallsyms include
Date: Sun, 17 Dec 2017 19:04:37 +0100
Message-ID: <2204687.eed4zNc3av@aspire.rjw.lan>
In-Reply-To: <20171208144909.GB489@tigerII.localdomain>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com> <CAJZ5v0hQ+QyJZ_bw9AGaSByvckpK5MeU=jkuy-MYg4Qdzoxrrw@mail.gmail.com> <20171208144909.GB489@tigerII.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Friday, December 8, 2017 3:49:09 PM CET Sergey Senozhatsky wrote:
> On (12/08/17 15:02), Rafael J. Wysocki wrote:
> > On Fri, Dec 8, 2017 at 3:56 AM, Sergey Senozhatsky
> > <sergey.senozhatsky.work@gmail.com> wrote:
> > > The file was converted from print_fn_descriptor_symbol()
> > > to %pF some time ago (2e532d68a2b3e2aa {pci,pnp} quirks.c:
> > > don't use deprecated print_fn_descriptor_symbol()). kallsyms
> > > does not seem to be needed anymore.
> > >
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Cc: Bjorn Helgaas <bhelgaas@google.com>
> > > ---
> > >  drivers/pnp/quirks.c | 1 -
> > >  1 file changed, 1 deletion(-)
> > >
> > > diff --git a/drivers/pnp/quirks.c b/drivers/pnp/quirks.c
> > > index f054cdddfef8..803666ae3635 100644
> > > --- a/drivers/pnp/quirks.c
> > > +++ b/drivers/pnp/quirks.c
> > > @@ -21,7 +21,6 @@
> > >  #include <linux/slab.h>
> > >  #include <linux/pnp.h>
> > >  #include <linux/io.h>
> > > -#include <linux/kallsyms.h>
> > >  #include "base.h"
> > >
> > >  static void quirk_awe32_add_ports(struct pnp_dev *dev,
> > > --
> > 
> > Do you want me to apply this or do you want to route it differently?
> 
> please pick it up.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

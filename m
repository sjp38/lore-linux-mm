Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3ADE6B025F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 09:37:55 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i7so5504571plt.3
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:37:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor1768001pld.6.2017.12.18.06.37.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 06:37:54 -0800 (PST)
Date: Mon, 18 Dec 2017 23:37:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 3/9] power: remove unneeded kallsyms include
Message-ID: <20171218143751.GA5053@tigerII.localdomain>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <CAJZ5v0g1CBhKTYi=CzYPcBXdH=yZ3iJcKzZ6TaftNWoq+X5wnQ@mail.gmail.com>
 <20171208144844.GA489@tigerII.localdomain>
 <4033333.ijW7uRe5gx@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4033333.ijW7uRe5gx@aspire.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On (12/17/17 19:04), Rafael J. Wysocki wrote:
[..]
> > > Do you want me to apply this or do you want to route it differently?
> > 
> > Hello Rafael,
> > 
> > don't mind if you'll pick it up.
> 
> OK, applied now.
> 
> Thanks!

thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

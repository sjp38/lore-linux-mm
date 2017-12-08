Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 440D36B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 17:24:47 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v69so6734771wrb.3
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 14:24:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o3si6699965wrh.8.2017.12.08.14.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 14:24:45 -0800 (PST)
Date: Fri, 8 Dec 2017 14:24:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/9] remove some of unneeded kallsyms includes
Message-Id: <20171208142442.7c09406d7f0bc3d2c1bfe411@linux-foundation.org>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri,  8 Dec 2017 11:56:07 +0900 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> 	A small patch set that removes some kallsyms includes
> here and there. Mostly those kallsyms includes are leftovers:
> printk() gained %pS/%pF modifiers support some time ago, so
> print_symbol() and friends became sort of unneeded [along with
> print_fn_descriptor_symbol() deprecation], thus some of the
> users were converted to pS/pF. This patch set just cleans up
> that convertion.
> 
> 	We still have a number of print_symbol() users [which
> must be converted to ps/pf, print_symbol() uses a stack buffer
> KSYM_SYMBOL_LEN to do what printk(ps/pf) can do], but this is
> out of scope.
> 
> 	I compile tested the patch set; but, as always and
> usual, would be great if 0day build robot double check it.

I grabbed everything and shall drop any patches which later turn up in
the various subsystem trees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

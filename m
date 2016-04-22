Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADCA6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 14:30:43 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id c103so93373395qge.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 11:30:43 -0700 (PDT)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id n10si2594178ybc.234.2016.04.22.11.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 11:30:42 -0700 (PDT)
Received: by mail-yw0-x243.google.com with SMTP id o63so16564507ywe.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 11:30:42 -0700 (PDT)
Date: Fri, 22 Apr 2016 14:30:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 00/20] kthread: Use kthread worker API more widely
Message-ID: <20160422183040.GW7822@mtj.duckdns.org>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, linux-watchdog@vger.kernel.org, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Maxim Levitsky <maximlevitsky@gmail.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Hello, Petr.

On Thu, Apr 14, 2016 at 05:14:19PM +0200, Petr Mladek wrote:
> My intention is to make it easier to manipulate and maintain kthreads.
> Especially, I want to replace all the custom main cycles with a
> generic one. Also I want to make the kthreads sleep in a consistent
> state in a common place when there is no work.
> 
> My first attempt was with a brand new API (iterant kthread), see
> http://thread.gmane.org/gmane.linux.kernel.api/11892 . But I was
> directed to improve the existing kthread worker API. This is
> the 4th iteration of the new direction.
> 
> 1nd..10th patches: improve the existing kthread worker API

I glanced over them and they generally look good to me.  Let's see how
people respond to actual conversions.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

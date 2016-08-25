Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7670083090
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:33:43 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so27023231lfg.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 01:33:43 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id tn19si12677616wjb.284.2016.08.25.01.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 01:33:42 -0700 (PDT)
Date: Thu, 25 Aug 2016 10:33:17 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v6 20/20] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160825083316.myqbas7d6gtv62c6@linutronix.de>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
 <1460646879-617-21-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1460646879-617-21-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

On 2016-04-14 17:14:39 [+0200], Petr Mladek wrote:
> Kthreads are currently implemented as an infinite loop. Each
> has its own variant of checks for terminating, freezing,
> awakening. In many cases it is unclear to say in which state
> it is and sometimes it is done a wrong way.

What is the status of this? This is the last email I received and it is
from April.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

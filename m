Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 37D266B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:25:11 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so86530153pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:25:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qc8si34529976pac.39.2016.01.25.08.25.10
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 08:25:10 -0800 (PST)
Date: Mon, 25 Jan 2016 08:23:54 -0800
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v4 21/22] thermal/intel_powerclamp: Remove duplicated
 code that starts the kthread
Message-ID: <20160125082354.02424350@icelake>
In-Reply-To: <1453736711-6703-22-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
	<1453736711-6703-22-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org, jacob.jun.pan@linux.intel.com

On Mon, 25 Jan 2016 16:45:10 +0100
Petr Mladek <pmladek@suse.com> wrote:

> This patch removes a code duplication. It does not modify
> the functionality.
> 
Acked-by:Jacob Pan <jacob.jun.pan@linux.intel.com>

> Signed-off-by: Petr Mladek <pmladek@suse.com>
> CC: Zhang Rui <rui.zhang@intel.com>
> CC: Eduardo Valentin <edubezval@gmail.com>
> CC: Jacob Pan <jacob.jun.pan@linux.intel.com>
> CC: linux-pm@vger.kernel.org
> ---
>  drivers/thermal/intel_powerclamp.c | 45
> +++++++++++++++++--------------------- 1 file changed, 20
> insertions(+), 25 deletions(-)

[Jacob Pan]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

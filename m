Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFAA6B025F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:57:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l81so405194222qke.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:57:18 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id v66si7352692ybe.40.2016.06.20.12.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 12:57:17 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id i12so2802073ywa.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:57:17 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:57:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 07/12] kthread: Add kthread_destroy_worker()
Message-ID: <20160620195716.GY3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-8-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-8-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:26PM +0200, Petr Mladek wrote:
> The current kthread worker users call flush() and stop() explicitly.
> This function drains the worker, stops it, and frees the kthread_worker
> struct in one call.
> 
> It is supposed to be used together with kthread_create_worker*() that
> allocates struct kthread_worker.
> 
> Also note that drain() correctly handles self-queuing works in compare
> with flush().
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

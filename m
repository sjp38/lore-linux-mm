Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5748A6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:30:12 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so18420778ykd.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:30:12 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id n184si1810662ywb.98.2015.09.22.11.30.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:30:11 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so18420423ykd.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:30:11 -0700 (PDT)
Date: Tue, 22 Sep 2015 14:30:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 04/18] kthread: Add destroy_kthread_worker()
Message-ID: <20150922183006.GC17659@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-5-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-5-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Sep 21, 2015 at 03:03:45PM +0200, Petr Mladek wrote:
...
> Note that flush() does not guarantee that the queue is empty. drain()
> is more safe. It returns when the queue is really empty. Also it warns

Maybe it'd be better to be a bit more specific.  drain() is safer
because it can handle self-requeueing work items.

> when too many work is being queued when draining.
...
> +/**
> + * destroy_kthread_worker - destroy a kthread worker
> + * @worker: worker to be destroyed
> + *
> + * Destroy @worker. It should be idle when this is called.

So, no new work item should be queued from this point on but @worker
is allowed to be not idle.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A118E6B025E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:56:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l81so405169467qke.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:56:45 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id v63si19824201ywd.410.2016.06.20.12.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 12:56:45 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id f75so3598583ywb.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:56:44 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:56:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160620195643.GX3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-7-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:25PM +0200, Petr Mladek wrote:
> kthread_flush_worker() returns when the currently queued works are proceed.
> But some other works might have been queued in the meantime.
> 
> This patch adds kthread_drain_worker() that is inspired by
> drain_workqueue(). It returns when the queue is completely
> empty and warns when it takes too long.
> 
> The initial implementation does not block queuing new works when
> draining. It makes things much easier. The blocking would be useful
> to debug potential problems but it is not clear if it is worth
> the complication at the moment.
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

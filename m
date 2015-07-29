Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1C35D6B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:12:07 -0400 (EDT)
Received: by ykay190 with SMTP id y190so10142634yka.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:12:06 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id y16si18817478ywa.58.2015.07.29.08.12.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:12:06 -0700 (PDT)
Received: by ykax123 with SMTP id x123so10201802yka.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:12:06 -0700 (PDT)
Date: Wed, 29 Jul 2015 11:12:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 13/14] kthread_worker: Add
 set_kthread_worker_user_nice()
Message-ID: <20150729151202.GB3504@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-14-git-send-email-pmladek@suse.com>
 <20150728174058.GF5322@mtj.duckdns.org>
 <20150729112354.GK2673@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729112354.GK2673@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jul 29, 2015 at 01:23:54PM +0200, Petr Mladek wrote:
> My plan is to make the API cleaner and hide struct kthread_worker
> definition into kthread.c. It would prevent anyone doing any hacks
> with it. BTW, we do the same with struct workqueue_struct.

I think obsessive attachment to cleanliness tends to worse code in
general like simple several liner wrappers which don't do anything
other than increasing interface surface and obscuring what's going on.
Let's please take a reasonable trade-off.  It shouldn't be nasty but
we don't want to be paying unnecessary complexity for perfect purity
either.

> Another possibility would be to add helper function to get the
> associated task struct but this might cause inconsistencies when
> the worker is restarted.

A kthread_worker would be instantiated on the create call and released
on destroy and the caller is natrually expected to synchronize
creation and destruction against all other operations.  Nothing seems
complicated or subtle to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

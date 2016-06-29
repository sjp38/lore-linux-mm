Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC5E36B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 09:16:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x68so102678066ioi.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:16:02 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id m134si4717608ith.114.2016.06.29.06.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 06:16:02 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id 100so5236597ioh.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:16:02 -0700 (PDT)
Date: Wed, 29 Jun 2016 09:15:52 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 06/12] kthread: Add kthread_drain_worker()
Message-ID: <20160629131552.GA24054@htj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-7-git-send-email-pmladek@suse.com>
 <20160622205445.GV30909@twins.programming.kicks-ass.net>
 <20160623213258.GO3262@mtj.duckdns.org>
 <20160624070515.GU30154@twins.programming.kicks-ass.net>
 <20160624155447.GY3262@mtj.duckdns.org>
 <20160627143350.GA3313@pathway.suse.cz>
 <20160628170447.GE5185@htj.duckdns.org>
 <20160629081748.GA3238@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629081748.GA3238@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jun 29, 2016 at 10:17:48AM +0200, Petr Mladek wrote:
> > Ah, okay, I don't think we need to change this.  I was suggesting to
> > simplify it by dropping the draining and just do flush from destroy.
> 
> I see. But then it does not address the original concern from Peter
> Zijlstra. He did not like that the caller was responsible for blocking
> further queueing. It still will be needed. Or did I miss something,
> please?

You can only protect against so much.  Let's say we make the worker
struct to be allocated by the user, what then prevents it prematurely
from user side?  Use-after-free is use-after-free.  If we can trivally
add some protection against it, great, but no need to contort the
design to add marginal protection.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

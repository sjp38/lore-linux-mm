Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA2876B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 23:15:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n137so4318754iod.18
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 20:15:13 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0191.hostedemail.com. [216.40.44.191])
        by mx.google.com with ESMTPS id 65si1200287iti.86.2017.11.02.20.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 20:15:11 -0700 (PDT)
Date: Thu, 2 Nov 2017 23:15:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171102231507.18f6b3b6@vmware.local.home>
In-Reply-To: <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
References: <20171102134515.6eef16de@gandalf.local.home>
	<82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Thu, 2 Nov 2017 23:16:16 +0100
Vlastimil Babka <vbabka@suse.cz> wrote:

> > +			if (spin) {
> > +				/* We spin waiting for the owner to release us */
> > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +				/* Owner will clear console_waiter on hand off */
> > +				while (!READ_ONCE(console_waiter))  
> 
> This should not be negated, right? We should spin while it's true, not
> false.

Ug, yes. How did that not crash in my tests.

Will fix.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 432806B025F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:36:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p9so2838736pgc.6
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:36:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p17si1321881pgq.130.2017.11.01.08.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 08:36:50 -0700 (PDT)
Date: Wed, 1 Nov 2017 11:36:47 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171101113647.243eecf8@gandalf.local.home>
In-Reply-To: <20171101133845.GF20040@pathway.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171031153225.218234b4@gandalf.local.home>
	<187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
	<20171101133845.GF20040@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Wed, 1 Nov 2017 14:38:45 +0100
Petr Mladek <pmladek@suse.com> wrote:

> This was my fear as well. Steven argued that this was theoretical.
> And I do not have a real-life bullets against this argument at
> the moment.

And my argument is still if such a situation happens, the system is so
fscked up that it should just crash.

> 
> My current main worry with Steven's approach is a risk of deadlocks
> that Jan Kara saw when he played with similar solution.

And if there exists such a deadlock, then the deadlock exists today.

> 
> Also I am afraid that it would add yet another twist to the console
> locking operations. It is already quite hard to follow the logic,
> see the games with:
> 
> 	+ console_locked
> 	+ console_suspended
> 	+ can_use_console()
> 	+ exclusive_console
> 
> And Steven is going to add:
> 
> 	+ console_owner
> 	+ waiter

Agreed. Console_lock is just ugly. And this may just make it uglier :-/

> 
> But let's wait for the patch. It might look and work nicely
> in the end.

Oh, I need to write a patch? Bah, I guess I should. Where's all those
developers dying to do kernel programing where I can pass this off to?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F27EE6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:14:29 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id r27so4085888lfi.11
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:14:29 -0800 (PST)
Received: from mail02.prevas.se (mail02.prevas.se. [62.95.78.10])
        by mx.google.com with ESMTPS id j23si2756804ljb.29.2018.01.17.11.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 11:14:28 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <20180112115454.17c03c8f@gandalf.local.home>
 <20180112121148.20778932@gandalf.local.home>
From: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Message-ID: <2c4e5175-e806-02f9-1467-081a9f533de1@prevas.dk>
Date: Wed, 17 Jan 2018 20:13:28 +0100
MIME-Version: 1.0
In-Reply-To: <20180112121148.20778932@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On 2018-01-12 18:11, Steven Rostedt wrote:
> On Fri, 12 Jan 2018 11:54:54 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
>> #include <linux/module.h>
>> #include <linux/delay.h>
>> #include <linux/sched.h>
>> #include <linux/mutex.h>
>> #include <linux/workqueue.h>
>> #include <linux/hrtimer.h>
>>
>>
> 
> 
>>
>> Hmm, how does one have git commit not remove the C preprocessor at the
>> start of the module?
> 
> Probably just add a space in front of the entire program.

If you use at least git 2.0.0 [1], set commit.cleanup to "scissors".
Something like

  git config commit.cleanup scissors

should do the trick. Instead of stripping all lines starting with #,
that will only strip stuff below a line containing

# ------------------------ >8 ------------------------

and git should be smart enough to insert that in the editor it fires up
for a commit message.


[1] https://github.com/git/git/blob/master/Documentation/RelNotes/2.0.0.txt

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

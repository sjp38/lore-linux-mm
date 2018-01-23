Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84753800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:56:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a9so477008pff.0
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 06:56:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a23si1575791pfe.414.2018.01.23.06.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 06:56:55 -0800 (PST)
Date: Tue, 23 Jan 2018 09:56:52 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123095652.5e14da85@gandalf.local.home>
In-Reply-To: <20180123064023.GA492@jagdpanzerIV>
References: <20180111215547.2f66a23a@gandalf.local.home>
	<20180116194456.GS3460072@devbig577.frc2.facebook.com>
	<20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
	<20180117151509.GT3460072@devbig577.frc2.facebook.com>
	<20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
	<20180119132052.02b89626@gandalf.local.home>
	<20180120071402.GB8371@jagdpanzerIV>
	<20180120104931.1942483e@gandalf.local.home>
	<20180121141521.GA429@tigerII.localdomain>
	<20180123064023.GA492@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, 23 Jan 2018 15:40:23 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> Why do we even use irq_work for printk_safe?

Why not?

Really, I think you are trying to solve a symptom and not the problem.
If we are having issues with irq_work, we are going to have issues with
a work queue. It's just spreading out the problem instead of fixing it.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

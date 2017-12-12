Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF4DC6B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:27:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y62so18639440pfd.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:27:15 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d3si12153101pln.700.2017.12.12.11.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 11:27:14 -0800 (PST)
Date: Tue, 12 Dec 2017 14:27:10 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171212142710.21e82ecd@gandalf.local.home>
In-Reply-To: <20171212053921.GA1392@jagdpanzerIV>
References: <20171108102723.602216b1@gandalf.local.home>
	<20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
	<20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
	<20171128014229.GA2899@X58A-UD3R>
	<20171208140022.uln4t5e5drrhnvvt@pathway.suse.cz>
	<20171212053921.GA1392@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Byungchul Park <byungchul.park@lge.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

On Tue, 12 Dec 2017 14:39:21 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> p.s.
> frankly, I don't see any "locking issues" in Steven's patch.

Should I push out another revision of mine?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

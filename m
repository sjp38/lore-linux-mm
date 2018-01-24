Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 904CE800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:52:39 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so1813454pfd.7
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 18:52:39 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y28si9864308pgc.742.2018.01.23.18.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 18:52:38 -0800 (PST)
Date: Tue, 23 Jan 2018 21:52:34 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123215234.709c845a@vmware.local.home>
In-Reply-To: <20180124021034.GA651@jagdpanzerIV>
References: <20180119132052.02b89626@gandalf.local.home>
	<20180120071402.GB8371@jagdpanzerIV>
	<20180120104931.1942483e@gandalf.local.home>
	<20180121141521.GA429@tigerII.localdomain>
	<20180123064023.GA492@jagdpanzerIV>
	<20180123095652.5e14da85@gandalf.local.home>
	<20180123152130.GB429@tigerII.localdomain>
	<20180123104121.2ef96d81@gandalf.local.home>
	<20180123160153.GC429@tigerII.localdomain>
	<20180123112436.0c94bc2e@gandalf.local.home>
	<20180124021034.GA651@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 24 Jan 2018 11:11:33 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> Please take a look.

Was there something specific to look at?

I'm doing a hundred different things at once, and my memory cache keeps
getting flushed.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

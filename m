Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D57D6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 10:22:52 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u26so3962047pfi.3
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:22:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z18si7022739pfe.221.2018.01.18.07.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 07:22:51 -0800 (PST)
Date: Thu, 18 Jan 2018 10:22:47 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180118102247.1f2bba42@gandalf.local.home>
In-Reply-To: <20180118043116.GA6529@jagdpanzerIV>
References: <20180112100544.GA441@jagdpanzerIV>
	<20180112072123.33bb567d@gandalf.local.home>
	<20180113072834.GA1701@tigerII.localdomain>
	<20180115070637.1915ac20@gandalf.local.home>
	<20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
	<20180116022349.GD6607@jagdpanzerIV>
	<20180116044716.GE6607@jagdpanzerIV>
	<20180116104508.515ca393@gandalf.local.home>
	<20180117021856.GA423@jagdpanzerIV>
	<20180117130407.unwy6noeorzretvn@pathway.suse.cz>
	<20180118043116.GA6529@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 18 Jan 2018 13:31:16 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> d'oh... indeed, I copy-pasted the wrong URL... it should
> have been lkml.kernel.org/r/ [and it actually was].

I've learned to do a copy after entering the lkml.kernel.org link into
the browser url, and before hitting enter. The redirection kills you.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

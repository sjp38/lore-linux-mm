Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 095426B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:08:47 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so5402033pfi.15
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:08:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si13865957pgp.293.2018.01.12.08.08.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jan 2018 08:08:45 -0800 (PST)
Date: Fri, 12 Jan 2018 17:08:37 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180112160837.GD24497@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-3-pmladek@suse.com>
 <20180110125220.69f5f930@vmware.local.home>
 <20180111120341.GB24419@linux.suse>
 <20180112103754.1916a1e2@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112103754.1916a1e2@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri 2018-01-12 10:37:54, Steven Rostedt wrote:
> On Thu, 11 Jan 2018 13:03:41 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> > All the other changes look good to me. I will use them in the next version.
> 
> Great.

Please, find below the updated version. If I get Ack at least from
Steven and no nack's, I will put it into linux-next next week.

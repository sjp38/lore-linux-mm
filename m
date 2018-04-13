Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D90E6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:12:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q9so1618692pgs.10
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:12:38 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u10si4000683pgr.221.2018.04.13.07.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 07:12:36 -0700 (PDT)
Date: Fri, 13 Apr 2018 10:12:33 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180413101233.0792ebf0@gandalf.local.home>
In-Reply-To: <20180413124704.19335-1-pmladek@suse.com>
References: <20180413124704.19335-1-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org

On Fri, 13 Apr 2018 14:47:04 +0200
Petr Mladek <pmladek@suse.com> wrote:


> The interval is set to one hour. It is rather arbitrary selected time.
> It is supposed to be a compromise between never print these messages,
> do not lockup the machine, do not fill the entire buffer too quickly,
> and get information if something changes over time.


I think an hour is incredibly long. We only allow 100 lines per hour for
printks happening inside another printk?

I think 5 minutes (at most) would probably be plenty. One minute may be
good enough.

-- Steve

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC2C66B03A2
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:06:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l43so53311788wre.4
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:06:07 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id b48si4637991wra.295.2017.03.28.06.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 06:06:06 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id w43so19713237wrb.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:06:06 -0700 (PDT)
Date: Tue, 28 Mar 2017 15:06:04 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170328130602.GA4216@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
 <CANRm+Cwb3uAiZdufqDsyzQ1GZYh3nUr2uTyg1Hb2oVoxJZKMvg@mail.gmail.com>
 <20170328122642.dhw2zkjbghfw4fzn@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328122642.dhw2zkjbghfw4fzn@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wanpeng Li <kernellwp@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Tue, Mar 28, 2017 at 02:26:42PM +0200, Peter Zijlstra wrote:
> On Tue, Mar 28, 2017 at 06:34:52PM +0800, Wanpeng Li wrote:
> > 
> > sched_clock_cpu(cpu) should be converted from cputime to ns.
> 
> Uhm, no. sched_clock_cpu() returns u64 in ns.

Yes, and most of the cputime_t have been converted to u64 so there
should be no such conversion issue between u64 and cputime_t anymore.

Perhaps my commit has another side effect on softirq time accounting,
I'll see if I can reproduce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

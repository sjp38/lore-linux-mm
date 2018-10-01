Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6BBE6B0008
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 16:30:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h76-v6so12983986pfd.10
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:30:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y129-v6si12944700pgy.551.2018.10.01.13.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 13:30:02 -0700 (PDT)
Date: Mon, 1 Oct 2018 16:29:58 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181001162958.3b8e4640@gandalf.local.home>
In-Reply-To: <20181001201309.GA9835@amd>
References: <20180927194601.207765-1-wonderfly@google.com>
	<20181001152324.72a20bea@gandalf.local.home>
	<20181001201309.GA9835@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, pfeiner@google.com

On Mon, 1 Oct 2018 22:13:10 +0200
Pavel Machek <pavel@ucw.cz> wrote:

> > > [1] https://lore.kernel.org/lkml/20180409081535.dq7p5bfnpvd3xk3t@pathway.suse.cz/T/#u
> > > 
> > > Serial console logs leading up to the deadlock. As can be seen the stack trace
> > > was incomplete because the printing path hit a timeout.  
> > 
> > I'm fine with having this backported.  
> 
> Dunno. Is the patch perhaps a bit too complex? This is not exactly
> trivial bugfix.
> 
> pavel@duo:/data/l/clean-cg$ git show dbdda842fe96f | diffstat
>  printk.c |  108
>  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 
> I see that it is pretty critical to Daniel, but maybe kernel with
> console locking redone should no longer be called 4.4?

But it prevents a deadlock.

I usually weigh backporting as benefit vs risk. And I believe the
benefit outweighs the risk in this case.

-- Steve

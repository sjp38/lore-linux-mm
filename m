Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E07A96B0005
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 21:23:33 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m3-v6so4337894plt.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 18:23:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q10-v6si17226108pgk.392.2018.10.02.18.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 18:23:32 -0700 (PDT)
Date: Tue, 2 Oct 2018 21:23:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181002212327.7aab0b79@vmware.local.home>
In-Reply-To: <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
References: <20180927194601.207765-1-wonderfly@google.com>
	<20181001152324.72a20bea@gandalf.local.home>
	<CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
	<20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
	<CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Petr Mladek <pmladek@suse.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Tue, 2 Oct 2018 17:15:17 -0700
Daniel Wang <wonderfly@google.com> wrote:

> On Tue, Oct 2, 2018 at 1:42 AM Petr Mladek <pmladek@suse.com> wrote:
> >
> > Well, I still wonder why it helped and why you do not see it with 4.4.
> > I have a feeling that the console owner switch helped only by chance.
> > In fact, you might be affected by a race in
> > printk_safe_flush_on_panic() that was fixed by the commit:
> >
> > 554755be08fba31c7 printk: drop in_nmi check from printk_safe_flush_on_panic()
> >
> > The above one commit might be enough. Well, there was one more
> > NMI-related race that was fixed by:
> >
> > ba552399954dde1b printk: Split the code for storing a message into the log buffer
> > a338f84dc196f44b printk: Create helper function to queue deferred console handling
> > 03fc7f9c99c1e7ae printk/nmi: Prevent deadlock when accessing the main log buffer in NMI  
> 
> All of these commits already exist in 4.14 stable, since 4.14.68. The deadlock
> still exists even when built from 4.14.73 (latest tag) though. And cherrypicking
> dbdda842fe96 fixes it.
> 

I don't see the big deal of backporting this. The biggest complaints
about backports are from fixes that were added to late -rc releases
where the fixes didn't get much testing. This commit was added in 4.16,
and hasn't had any issues due to the design. Although a fix has been
added:

c14376de3a1 ("printk: Wake klogd when passing console_lock owner")

Also from 4.16, but nothing else according to searching for "Fixes"
tags.

-- Steve

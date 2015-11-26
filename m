Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1FD6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 06:33:52 -0500 (EST)
Received: by oiww189 with SMTP id w189so45548864oiw.3
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:33:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rk8si8064857oeb.17.2015.11.26.03.33.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 03:33:51 -0800 (PST)
Subject: Re: WARNING in handle_mm_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
	<201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp>
	<CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
	<20151125173730.GS27283@dhcp22.suse.cz>
	<CACT4Y+Y0EESD_HhgGE2pWPqfJsDgvSny=ZMfP1ewaSzd6z_bLg@mail.gmail.com>
In-Reply-To: <CACT4Y+Y0EESD_HhgGE2pWPqfJsDgvSny=ZMfP1ewaSzd6z_bLg@mail.gmail.com>
Message-Id: <201511262033.EAB48965.FVJOOOMLFHStFQ@I-love.SAKURA.ne.jp>
Date: Thu, 26 Nov 2015 20:33:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, syzkaller@googlegroups.com
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kcc@google.com, glider@google.com, sasha.levin@oracle.com, edumazet@google.com, gthelen@google.com, tj@kernel.org, peterz@infradead.org

Dmitry Vyukov wrote:
> On Wed, Nov 25, 2015 at 6:37 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 25-11-15 18:21:02, Dmitry Vyukov wrote:
> > [...]
> >> I have some progress.
> >
> > Please have a look at Peter's patch posted in the original email thread
> > http://lkml.kernel.org/r/20151125150207.GM11639@twins.programming.kicks-ass.net
> 
> Yes, I've posted there as well. That patch should help.
> 
OK. This bug seems to exist since commit ca94c442535a "sched: Introduce
SCHED_RESET_ON_FORK scheduling policy flag". Should

  Cc: <stable@vger.kernel.org>  [2.6.32+]

line be added?

By the way, does use of "unsigned char" than "unsigned" save some bytes?
Simply trying not to change the size of "struct task_struct"...
According to C99, only "unsigned int", "signed int" and "_Bool" are
allowed. But many compilers accept other types such as "unsigned char",
given that we watch out for compiler bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

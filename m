Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8431D6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:54:58 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x8-v6so4131576pgp.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:54:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n26-v6si6252062pfe.116.2018.10.24.15.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 15:54:57 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:54:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,oom: Use timeout based back off.
Message-Id: <20181024155454.4e63191fbfaa0441f2e62f56@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
References: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Mon, 22 Oct 2018 14:11:10 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > Michal has been refusing timeout based approach, but I don't think this
> > is something we have to be frayed around the edge about possibility of
> > overlooking races/bugs just because Michal does not want to use timeout.
> > I believe that timeout based back off is the only approach we can use
> > for now.
> > 
> 
> I've proposed patches that have been running for months in a production 
> environment that make the oom killer useful without serially killing many 
> processes unnecessarily.  At this point, it is *much* easier to just fork 
> the oom killer logic rather than continue to invest time into fixing it in 
> Linux.  That's unfortunate because I'm sure you realize how problematic 
> the current implementation is, how abusive it is, and have seen its 
> effects yourself.  I admire your persistance in trying to fix the issues 
> surrounding the oom killer, but have come to the conclusion that forking 
> it is a much better use of time.

The oom killer is, I think, fairly standalone and it shouldn't be too
hard to add the infrastructure to make the whole thing pluggable.  At
runtime, not at build time.

But it is a last resort - it will result in fragmented effort and
difficult decisions for everyone regarding which should be used.

There has been a lot of heat and noise and confusion and handwaving in
all of this.  What we're crying out for is simple testcases which
everyone can run.  Find a problem, write the testcase, distribute that.
Develop a solution for that testcase then move on to the next one.

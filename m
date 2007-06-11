Date: Mon, 11 Jun 2007 18:50:33 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070611165032.GJ7443@v2.random>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random> <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com> <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com> <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random> <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 09:07:59AM -0700, Christoph Lameter wrote:
> Filtering tasks is a very expensive operation on huge systems. We have had 

Come on, oom_kill.c only happens at oom time, after the huge complex
processing has figured out it's time to call into oom_kill.c, how can
you care about the performance of oom_kill.c?  Apparently some folks
prefer to panic when oom triggers go figure...

> cases where it took an hour or so for the OOM to complete. OOM usually 
> occurs under heavy processing loads which makes the taking of global locks 
> quite expensive.

Since you mean that a _global_ OOM took one hour (you just used it as
the comparison of the slow-one, the local-oom is supposed to be the
fast one instead) I'd appreciate if you could try again with all my
fixes applied and see if the time to recover the global oom is reduced
(which is the whole objective of most of the fixes I've just
posted).

In general whatever you do inside oom_kill.c has nothing to do with
the "expensive operations" (the expensive operations are infact halted
with my fixes).

In turn killing the current task so that oom_kill.c is faster, is
quite a dubious argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

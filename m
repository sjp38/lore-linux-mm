Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8226B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:54:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z62so6822727wrc.0
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:54:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si25746858wrk.214.2017.04.11.04.54.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 04:54:32 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:54:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170411115428.GI6729@dhcp22.suse.cz>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
 <20170411071552.GA6729@dhcp22.suse.cz>
 <201704112043.EBD39096.JtFLQHVOFOFMOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704112043.EBD39096.JtFLQHVOFOFMOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Tue 11-04-17 20:43:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 10-04-17 15:03:08, Andrew Morton wrote:
> > > On Mon, 10 Apr 2017 20:58:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > > 
> > > > Patch "mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"
> > > > changed to drop __GFP_NOWARN when calling warn_alloc() for stall warning.
> > > > Although I suggested for two times to drop __GFP_NOWARN when warn_alloc()
> > > > for stall warning was proposed, Michal Hocko does not want to print stall
> > > > warnings when __GFP_NOWARN is given [1][2].
> > > > 
> > > >  "I am not going to allow defining a weird __GFP_NOWARN semantic which
> > > >   allows warnings but only sometimes. At least not without having a proper
> > > >   way to silence both failures _and_ stalls or just stalls. I do not
> > > >   really thing this is worth the additional gfp flag."
> > > 
> > > I interpret __GFP_NOWARN to mean "don't warn about this allocation
> > > attempt failing", not "don't warn about anything at all".  It's a very
> > > minor issue but yes, methinks that stall warning should still come out.
> > 
> > This is what the patch from Johannes already does and you have it in the
> > mmotm tree.
> > 
> > > Unless it's known to cause a problem for the stall warning to come out
> > > for __GFP_NOWARN attempts?  If so then perhaps a
> > > __GFP_NOWARN_ABOUT_STALLS is needed?
> > 
> > And this is one of the reason why I didn't like it. But whatever it
> > doesn't make much sense to spend too much time discussing this again.
> > This patch doesn't really fix anything important IMHO and it just
> > generates more churn.
> 
> This patch does not fix anything important for Michal Hocko, but
> this patch does find something important (e.g. GFP_NOFS | __GFP_NOWARN
> allocations)

I fail to see where it does that.

> for administrators and troubleshooting staffs at support
> centers. As a troubleshooting staff, giving administrators some clue to
> start troubleshooting is critically important.
> 
> Speak from my experience, hardcoded 10 seconds is really useless.
> Some cluster system has only 10 seconds timeout for failover. Failing
> to report allocations stalls longer than a few seconds can make this
> warn_alloc() pointless. On the other hand, some administrators do not
> want to receive this warn_alloc(). If we had tunable interface like
> /proc/sys/kernel/memalloc_task_warning_secs , we can handle both cases
> (assuming that stalling allocations can reach this warn_alloc() within
> a few seconds; if this assumption does not hold, only allocation watchdog
> can handle it).

This repeating of "hypotetical" demand of tunable is getting boring. I
would really appreciate to see at least _one_ such report from the
field. If you do not have any please stop wasting others people time by
unfounded claims.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

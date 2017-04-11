Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6A16B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 03:15:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u18so18305515wrc.17
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:15:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x66si1728201wme.98.2017.04.11.00.15.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 00:15:55 -0700 (PDT)
Date: Tue, 11 Apr 2017 09:15:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170411071552.GA6729@dhcp22.suse.cz>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 10-04-17 15:03:08, Andrew Morton wrote:
> On Mon, 10 Apr 2017 20:58:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > Patch "mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"
> > changed to drop __GFP_NOWARN when calling warn_alloc() for stall warning.
> > Although I suggested for two times to drop __GFP_NOWARN when warn_alloc()
> > for stall warning was proposed, Michal Hocko does not want to print stall
> > warnings when __GFP_NOWARN is given [1][2].
> > 
> >  "I am not going to allow defining a weird __GFP_NOWARN semantic which
> >   allows warnings but only sometimes. At least not without having a proper
> >   way to silence both failures _and_ stalls or just stalls. I do not
> >   really thing this is worth the additional gfp flag."
> 
> I interpret __GFP_NOWARN to mean "don't warn about this allocation
> attempt failing", not "don't warn about anything at all".  It's a very
> minor issue but yes, methinks that stall warning should still come out.

This is what the patch from Johannes already does and you have it in the
mmotm tree.

> Unless it's known to cause a problem for the stall warning to come out
> for __GFP_NOWARN attempts?  If so then perhaps a
> __GFP_NOWARN_ABOUT_STALLS is needed?

And this is one of the reason why I didn't like it. But whatever it
doesn't make much sense to spend too much time discussing this again.
This patch doesn't really fix anything important IMHO and it just
generates more churn.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

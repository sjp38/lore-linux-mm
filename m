Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 759C66B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:03:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 68so130592297pgj.23
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 15:03:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j21si14729823pgg.373.2017.04.10.15.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 15:03:11 -0700 (PDT)
Date: Mon, 10 Apr 2017 15:03:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-Id: <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
In-Reply-To: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Mon, 10 Apr 2017 20:58:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Patch "mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"
> changed to drop __GFP_NOWARN when calling warn_alloc() for stall warning.
> Although I suggested for two times to drop __GFP_NOWARN when warn_alloc()
> for stall warning was proposed, Michal Hocko does not want to print stall
> warnings when __GFP_NOWARN is given [1][2].
> 
>  "I am not going to allow defining a weird __GFP_NOWARN semantic which
>   allows warnings but only sometimes. At least not without having a proper
>   way to silence both failures _and_ stalls or just stalls. I do not
>   really thing this is worth the additional gfp flag."

I interpret __GFP_NOWARN to mean "don't warn about this allocation
attempt failing", not "don't warn about anything at all".  It's a very
minor issue but yes, methinks that stall warning should still come out.

Unless it's known to cause a problem for the stall warning to come out
for __GFP_NOWARN attempts?  If so then perhaps a
__GFP_NOWARN_ABOUT_STALLS is needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

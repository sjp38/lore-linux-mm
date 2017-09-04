Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D92796B04A5
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 06:29:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l185so13141319oib.4
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 03:29:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e204si4226016oif.475.2017.09.04.03.29.35
        for <linux-mm@kvack.org>;
        Mon, 04 Sep 2017 03:29:35 -0700 (PDT)
Date: Mon, 4 Sep 2017 11:29:30 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/2] arm64: stacktrace: avoid listing stacktrace
 functions in stacktrace
Message-ID: <20170904102930.nuop6zscgp2frvat@armageddon.cambridge.arm.com>
References: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
 <20170830132828.0bf9b9bc64f51362a64a6694@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830132828.0bf9b9bc64f51362a64a6694@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Prakash Gupta <guptap@codeaurora.org>, mhocko@suse.com, vbabka@suse.cz, will.deacon@arm.com, iamjoonsoo.kim@lge.com, rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 30, 2017 at 01:28:28PM -0700, Andrew Morton wrote:
> On Wed, 30 Aug 2017 13:02:22 +0530 Prakash Gupta <guptap@codeaurora.org> wrote:
> 
> > The stacktraces always begin as follows:
> > 
> >  [<c00117b4>] save_stack_trace_tsk+0x0/0x98
> >  [<c0011870>] save_stack_trace+0x24/0x28
> >  ...
> > 
> > This is because the stack trace code includes the stack frames for itself.
> > This is incorrect behaviour, and also leads to "skip" doing the wrong thing
> > (which is the number of stack frames to avoid recording.)
> > 
> > Perversely, it does the right thing when passed a non-current thread.  Fix
> > this by ensuring that we have a known constant number of frames above the
> > main stack trace function, and always skip these.
> > 
> > This was fixed for arch arm by Commit 3683f44c42e9 ("ARM: stacktrace: avoid
> > listing stacktrace functions in stacktrace")
> 
> I can take this (with acks, please?)

In case you haven't picked it up already:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

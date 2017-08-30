Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 629666B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:28:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a47so10251992wra.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:28:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n102si5061528wrb.416.2017.08.30.13.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 13:28:31 -0700 (PDT)
Date: Wed, 30 Aug 2017 13:28:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] arm64: stacktrace: avoid listing stacktrace
 functions in stacktrace
Message-Id: <20170830132828.0bf9b9bc64f51362a64a6694@linux-foundation.org>
In-Reply-To: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
References: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Gupta <guptap@codeaurora.org>
Cc: mhocko@suse.com, vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com, iamjoonsoo.kim@lge.com, rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 30 Aug 2017 13:02:22 +0530 Prakash Gupta <guptap@codeaurora.org> wrote:

> The stacktraces always begin as follows:
> 
>  [<c00117b4>] save_stack_trace_tsk+0x0/0x98
>  [<c0011870>] save_stack_trace+0x24/0x28
>  ...
> 
> This is because the stack trace code includes the stack frames for itself.
> This is incorrect behaviour, and also leads to "skip" doing the wrong thing
> (which is the number of stack frames to avoid recording.)
> 
> Perversely, it does the right thing when passed a non-current thread.  Fix
> this by ensuring that we have a known constant number of frames above the
> main stack trace function, and always skip these.
> 
> This was fixed for arch arm by Commit 3683f44c42e9 ("ARM: stacktrace: avoid
> listing stacktrace functions in stacktrace")

I can take this (with acks, please?)

3683f44c42e9 has a cc:stable but your patch does not.  Should it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

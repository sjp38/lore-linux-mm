Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id B0F106B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 11:36:26 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id lf12so2102150vcb.31
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:36:26 -0700 (PDT)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id wz6si3350306vcb.13.2014.05.30.08.36.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 08:36:26 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id lf12so2102138vcb.31
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:36:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFLxGvwJV+PJchoNEJjnge9CuBrxFJ3TPxcN_M+j1CdAW-GmNA@mail.gmail.com>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
	<20140529072633.GH6677@dastard>
	<CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>
	<CAFLxGvwJV+PJchoNEJjnge9CuBrxFJ3TPxcN_M+j1CdAW-GmNA@mail.gmail.com>
Date: Fri, 30 May 2014 08:36:25 -0700
Message-ID: <CA+55aFxD=ADreuGpEEr2U1SMJ90U-cJjy7HdenUPmUkQ3GVDQA@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, May 30, 2014 at 2:48 AM, Richard Weinberger
<richard.weinberger@gmail.com> wrote:
>
> If we raise the stack size on x86_64 to 16k, what about i386?
> Beside of the fact that most of you consider 32bits as dead and must die... ;)

x86-32 doesn't have nearly the same issue, since a large portion of
stack content tends to be pointers and longs. So it's not like it uses
half the stack, but a 32-bit environment does use a lot less stack
than a 64-bit one.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

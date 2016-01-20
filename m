Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7C56B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 22:59:37 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id 77so7422429ioc.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:59:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160115202131.GH6330@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
	<80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
	<20160112011128.GC6033@dastard>
	<CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
	<20160112022548.GD6033@dastard>
	<CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
	<20160112033708.GE6033@dastard>
	<CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
	<CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
	<20160115202131.GH6330@kvack.org>
Date: Tue, 19 Jan 2016 19:59:35 -0800
Message-ID: <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 15, 2016 at 12:21 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>>
>> I'll have to think about this some more.
>
> Any further thoughts on this after a few days worth of pondering?

Sorry about the delay, with the merge window and me being sick for a
couple of days I didn't get around to this.

After thinking it over some more, I guess I'm ok with your approach.
The table-driven patch makes me a bit happier, and I guess not very
many people end up ever wanting to do async system calls anyway.

Are there other users outside of Solace? It would be good to get comments..

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

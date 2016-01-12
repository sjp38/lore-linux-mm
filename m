Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id C0510680F84
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:38:16 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id z14so115657940igp.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:38:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160112022548.GD6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
	<80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
	<20160112011128.GC6033@dastard>
	<CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
	<20160112022548.GD6033@dastard>
Date: Mon, 11 Jan 2016 18:38:15 -0800
Message-ID: <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 6:25 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> That's a different interface.

So is openat. So is readahead.

My point is that this idiotic "let's expose special cases" must end.
It's broken. It inevitably only exposes a subset of what different
people would want.

Making "aio_read()" and friends a special interface had historical
reasons for it. But expanding willy-nilly on that model does not.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

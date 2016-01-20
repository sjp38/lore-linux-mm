Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 891B5828DF
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:00:03 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id z14so108556801igp.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 12:00:03 -0800 (PST)
Date: Thu, 21 Jan 2016 06:59:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160120195957.GV6033@dastard>
References: <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard>
 <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
 <20160112022548.GD6033@dastard>
 <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
 <20160112033708.GE6033@dastard>
 <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
 <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 19, 2016 at 07:59:35PM -0800, Linus Torvalds wrote:
> On Fri, Jan 15, 2016 at 12:21 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> >>
> >> I'll have to think about this some more.
> >
> > Any further thoughts on this after a few days worth of pondering?
> 
> Sorry about the delay, with the merge window and me being sick for a
> couple of days I didn't get around to this.
> 
> After thinking it over some more, I guess I'm ok with your approach.
> The table-driven patch makes me a bit happier, and I guess not very
> many people end up ever wanting to do async system calls anyway.
> 
> Are there other users outside of Solace? It would be good to get comments..

I know of quite a few storage/db products that use AIO. The most
recent high profile project that have been reporting issues with AIO
on XFS is http://www.scylladb.com/. That project is architected
around non-blocking AIO for scalability reasons...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

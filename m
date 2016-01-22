Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5946B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:41:13 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 123so19404538wmz.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:41:13 -0800 (PST)
Date: Fri, 22 Jan 2016 16:41:08 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160122154108.GG4961@awork2.anarazel.de>
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
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On 2016-01-19 19:59:35 -0800, Linus Torvalds wrote:
> Are there other users outside of Solace? It would be good to get comments..

PostgreSQL is a potential user of async fdatasync, fsync,
sync_file_range and potentially readahead, write, read. First tests with
Dave's async fsync/fsync_range are positive, so are the results with a
self-hacked async sync_file_range (although I'm kinda thinking that it
shouldn't really require to be used asynchronously).

I rather doubt openat, unlink et al are going to be interesting for
*us*, the requires structural changes would be too bit. But obviously
that doesn't mean anything for others.

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

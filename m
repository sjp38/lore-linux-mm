Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9C26B0140
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:20:13 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so8187739pbc.32
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:20:13 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id nd6si3619056pbc.354.2014.03.18.19.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 19:20:12 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so7998184pde.10
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:20:12 -0700 (PDT)
Date: Tue, 18 Mar 2014 19:19:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <20140319021131.GA30018@redhat.com>
Message-ID: <alpine.LSU.2.11.1403181918130.3423@eggly.anvils>
References: <531F0E39.9020100@oracle.com> <20140311134158.GD32390@moon> <20140311142817.GA26517@redhat.com> <20140311143750.GE32390@moon> <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com>
 <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <5328F3B4.1080208@oracle.com> <20140319020602.GA29787@redhat.com> <20140319021131.GA30018@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, 18 Mar 2014, Dave Jones wrote:
> On Tue, Mar 18, 2014 at 10:06:02PM -0400, Dave Jones wrote:
>  > On Tue, Mar 18, 2014 at 09:32:36PM -0400, Sasha Levin wrote:
>  >  
>  >  > > Untested patch below: I can't quite say Reported-by, because it may
>  >  > > not even be one that you and Sasha have been seeing; but I'm hopeful,
>  >  > > remap_file_pages is in the list.
>  >  > >
>  >  > > Please give this a try, preferably on 3.14-rc or earlier: I've never
>  >  > > seen "Bad rss-counter"s there myself (trinity uses remap_file_pages
>  >  > > a lot more than most of us); but have seen them on mmotm/next, so
>  >  > > some other trigger is coming up there, I'll worry about that once
>  >  > > it reaches 3.15-rc.
>  >  > 
>  >  > The patch fixed the "Bad rss-counter" errors I've been seeing both in
>  >  > 3.14-rc7 and -next.
>  >  
>  > It's looking good here too so far. I'll leave it running overnight to be sure.
> 
> Of course, that isn't going to happen. Immediately after posting this, I hit the
> swapops bug.  Patch does seem to have cured the bad rss counters though.

Another positive on the rss counters, great, thanks Dave.
That encourages me to think again on the swapops BUG, but no promises.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 03D836B0266
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 00:47:58 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so1910679pbc.34
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 21:47:58 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id zt8si2809922pbc.316.2014.03.20.21.47.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 21:47:54 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so1921515pad.30
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 21:47:53 -0700 (PDT)
Date: Thu, 20 Mar 2014 21:46:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <532AF8E8.8030101@oracle.com>
Message-ID: <alpine.LSU.2.11.1403202141310.1006@eggly.anvils>
References: <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com> <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <5328F3B4.1080208@oracle.com> <20140319020602.GA29787@redhat.com> <20140319021131.GA30018@redhat.com>
 <alpine.LSU.2.11.1403181918130.3423@eggly.anvils> <20140319145200.GA4608@redhat.com> <alpine.LSU.2.11.1403192147470.971@eggly.anvils> <20140320135137.GA2263@redhat.com> <532AF8E8.8030101@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 20 Mar 2014, Sasha Levin wrote:
> On 03/20/2014 09:51 AM, Dave Jones wrote:
> > On Wed, Mar 19, 2014 at 10:00:29PM -0700, Hugh Dickins wrote:
> > 
> >   > > This might be collateral damage from the swapops thing, I guess we
> > won't know until
> >   > > that gets fixed, but I thought I'd mention that we might still have a
> > problem here.
> >   >
> >   > Yes, those Bad rss-counters could well be collateral damage from the
> >   > swapops BUG.  To which I believe I now have the answer: again untested,
> >   > but please give this a try...
> > 
> > This survived an overnight run. No swapops bug, and no bad RSS. Good job:)
> 
> Same here, swapops bug is gone!

That was welcome news, thanks guys.  I notice it has not (yet) magically
appeared in Linus's public tree like the rss one did: so to be on the
safe side, I'll just repost it now, with your Reported-and-tested-bys,
otherwise unchanged.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

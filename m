Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E03EC6B013D
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:13:09 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so7938258pdj.36
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:13:09 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id tv5si10861354pbc.89.2014.03.18.19.13.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 19:13:08 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so8174367pbb.12
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:13:08 -0700 (PDT)
Date: Tue, 18 Mar 2014 19:12:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <5328F3B4.1080208@oracle.com>
Message-ID: <alpine.LSU.2.11.1403181906140.3318@eggly.anvils>
References: <20140311045109.GB12551@redhat.com> <20140310220158.7e8b7f2a.akpm@linux-foundation.org> <20140311053017.GB14329@redhat.com> <20140311132024.GC32390@moon> <531F0E39.9020100@oracle.com> <20140311134158.GD32390@moon> <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon> <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com> <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <5328F3B4.1080208@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, 18 Mar 2014, Sasha Levin wrote:
> On 03/18/2014 08:38 PM, Hugh Dickins wrote:
> > On Tue, 11 Mar 2014, Dave Jones wrote:
> > > On Tue, Mar 11, 2014 at 09:36:03PM +0400, Cyrill Gorcunov wrote:
> > >   > On Tue, Mar 11, 2014 at 01:10:45PM -0400, Dave Jones wrote:
> > >   > >  >
> > >   > >  > Dave, iirc trinity can write log file pointing which exactly
> > > syscall sequence
> > >   > >  > was passed, right? Share it too please.
> > >   > >
> > >   > > Hm, I may have been mistaken, and the damage was done by a previous
> > > run.
> > >   > > I went from being able to reproduce it almost instantly to now not
> > > being able
> > >   > > to reproduce it at all.  Will keep trying.
> > >   >
> > >   > Sasha already gave a link to the syscalls sequence, so no rush.
> > > 
> > > It'd be nice to get a more concise reproducer, his list had a little of
> > > everything in there.
> > 
> > I've so far failed to find any explanation for your swapops.h BUG;
> > but believe I have identified one cause for "Bad rss-counter"s.
> > 
> > My hunch is that the swapops.h BUG is "nearby", but I just cannot
> > fit it together (the swapops.h BUG comes when rmap cannot find all
> > all the migration entries it inserted earlier: it's a very useful
> > BUG for validating rmap).
> > 
> > Untested patch below: I can't quite say Reported-by, because it may
> > not even be one that you and Sasha have been seeing; but I'm hopeful,
> > remap_file_pages is in the list.
> > 
> > Please give this a try, preferably on 3.14-rc or earlier: I've never
> > seen "Bad rss-counter"s there myself (trinity uses remap_file_pages
> > a lot more than most of us); but have seen them on mmotm/next, so
> > some other trigger is coming up there, I'll worry about that once
> > it reaches 3.15-rc.
> 
> The patch fixed the "Bad rss-counter" errors I've been seeing both in
> 3.14-rc7 and -next.

Great, thanks a lot, Sasha.  I was afraid that you'd hit those swapops
BUGs, which seemed perhaps to be paired with these; but glad to hear
a positive.  Let's see how Dave fares.  (I've not forgotten shmem
fallocate, by the way, but those probably aren't as high on my agenda
as you'd like.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

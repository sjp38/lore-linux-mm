Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id AF1356B005C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:51:34 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2302077ggm.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 19:51:33 -0700 (PDT)
Date: Wed, 11 Jul 2012 19:50:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] tmpfs: revert SEEK_DATA and SEEK_HOLE
In-Reply-To: <20120711230122.GZ19223@dastard>
Message-ID: <alpine.LSU.2.00.1207111920210.1455@eggly.anvils>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils> <alpine.LSU.2.00.1207091535480.2051@eggly.anvils> <jtj574$tb7$2@dough.gmane.org> <alpine.LSU.2.00.1207111149580.1797@eggly.anvils> <20120711230122.GZ19223@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 12 Jul 2012, Dave Chinner wrote:
> On Wed, Jul 11, 2012 at 11:55:34AM -0700, Hugh Dickins wrote:
> > On Wed, 11 Jul 2012, Cong Wang wrote:
> > > 
> > > If you don't have burden to maintain it, I'd prefer to leave as it is,
> > > I don't think 752-bytes is the reason we revert it.
> > 
> > Thank you, your vote has been counted ;)
> > and I'll be glad if yours stimulates some agreement or disagreement.
> > 
> > But your vote would count for a lot more if you know of some app which
> > would really benefit from this functionality in tmpfs: I've heard of none.
> 
> So what? I've heard of no apps that use this functionality on XFS,
> either, but I have heard of a lot of people asking for it to be
> implemented over the past couple of years so they can use it.

I'd certainly not ask you to remove your support for it from XFS:
nobody would call XFS a minimal filesystem.

But tmpfs has a tradition and a duty to keep fairly small:
it needs to be useful, but it shouldn't be carrying unused baggage.

> There's been patches written to make coreutils (cp) make use of it
> instead of parsing FIEMAP output to find holes, though I don't know
> if that's gone beyond more than "here's some patches"....
> 
> Besides, given that you can punch holes in tmpfs files, it seems
> strange to then say "we don't need a method of skipping holes to
> find data quickly"....

tmpfs has been punching holes (via MADV_REMOVE) since 2.6.16 (and
that wasn't added on my whim, IBM wanted and did it).  But I haven't
heard of anybody asking for a method of skipping them in six years.

> 
> Besides, seek-hole/data is still shiny new and lots of developers
> aren't even aware of it's presence in recent kernels. Removing new
> functionality saying "no-one is using it" is like smashing the egg
> before the chicken hatches (or is it cutting of the chickes's head
> before it lays the egg?).

(You remind me of my chicken-and-egg sandwiches - you can't get them,
you see, it's chicken and egg.)

I'm not trying to remove SEEK_HOLE/SEEK_DATA support from the kernel:
I'm just saying that nobody has yet made the case for their usefulness
in tmpfs, so they're better removed from it before v3.5 is released.

Once we see how useful they have become in the grown-up filesystems,
or someone shows how useful they can be on tmpfs, then we reinstate.

Of course, I'm on both sides of this argument: I wrote that code,
I like it, I'll be glad to put it back when it's useful to someone.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

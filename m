Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id BD38D6B015A
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 07:04:40 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t61so6799301wes.2
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 04:04:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db6si9587047wib.25.2014.03.19.04.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 04:04:39 -0700 (PDT)
Date: Wed, 19 Mar 2014 12:04:36 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140319110436.GF26358@quack.suse.cz>
References: <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
 <20140311171045.GA4693@redhat.com>
 <20140311173603.GG32390@moon>
 <20140311173917.GB4693@redhat.com>
 <alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
 <CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
 <alpine.LSU.2.11.1403181848380.3318@eggly.anvils>
 <CA+55aFxVG7HLmsvCzoiA7PBRPvX3utRfyVGrBs6gVLZ-fUCuPQ@mail.gmail.com>
 <alpine.LSU.2.11.1403181928370.3499@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1403181928370.3499@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue 18-03-14 19:37:01, Hugh Dickins wrote:
> On Tue, 18 Mar 2014, Linus Torvalds wrote:
> > On Tue, Mar 18, 2014 at 7:06 PM, Hugh Dickins <hughd@google.com> wrote:
> > >
> > > I'd love that, if we can get away with it now: depends very
> > > much on whether we then turn out to break userspace or not.
> > 
> > Right. I suspect we can, though, but it's one of those "we can try it
> > and see". Remind me early in the 3.15 merge window, and we can just
> > turn the "force" case into an error case and see if anybody hollers.
> 
> Super, I'll do that, thanks.
> 
> For 3.15, and probably 3.16 too, we should keep in place whatever
> partial accommodations we have for the case (such as allowing for
> anon and swap in fremap's zap_pte), in case we do need to revert;
> but clean those away later on.  (Not many, I think: it was mainly
> a guilty secret that VM accounting didn't really hold together.)
  Different drivers actually use the 'force' argument of get_user_pages() a
lot on userspace provided buffers (AFAIU because they want to tell the
kernel HW is going to write to that memory so they want to prepare for it).
It is hard to imagine someone will use this for MAP_SHARED pages (or what
that would be supposed to achieve) but sometimes userspace is surprisingly
inventive... Just something to be aware of...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

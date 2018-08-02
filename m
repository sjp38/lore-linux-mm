Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B207C6B0007
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 08:26:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 17-v6so1833200qkz.15
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 05:26:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8-v6sor807831qks.32.2018.08.02.05.25.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 05:25:57 -0700 (PDT)
Date: Thu, 2 Aug 2018 08:28:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/9] mm: workingset: tell cache transitions from
 workingset thrashing
Message-ID: <20180802122852.GA17974@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-3-hannes@cmpxchg.org>
 <CAJuCfpGZGPD+k+jHDowWyvZPnUXzQ9n98wBycDZLAWOn=vV6Ew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpGZGPD+k+jHDowWyvZPnUXzQ9n98wBycDZLAWOn=vV6Ew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Suren,

On Wed, Aug 01, 2018 at 02:56:27PM -0700, Suren Baghdasaryan wrote:
> On Wed, Aug 1, 2018 at 8:19 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >         /*
> > -        * The unsigned subtraction here gives an accurate distance
> > -        * across inactive_age overflows in most cases.
> > +        * Calculate the refault distance
> >          *
> > -        * There is a special case: usually, shadow entries have a
> > -        * short lifetime and are either refaulted or reclaimed along
> > -        * with the inode before they get too old.  But it is not
> > -        * impossible for the inactive_age to lap a shadow entry in
> > -        * the field, which can then can result in a false small
> > -        * refault distance, leading to a false activation should this
> > -        * old entry actually refault again.  However, earlier kernels
> > -        * used to deactivate unconditionally with *every* reclaim
> > -        * invocation for the longest time, so the occasional
> > -        * inappropriate activation leading to pressure on the active
> > -        * list is not a problem.
> > +        * The unsigned subtraction here gives an accurate distance
> > +        * across inactive_age overflows in most cases. There is a
> > +        * special case: usually, shadow entries have a short lifetime
> > +        * and are either refaulted or reclaimed along with the inode
> > +        * before they get too old.  But it is not impossible for the
> > +        * inactive_age to lap a shadow entry in the field, which can
> > +        * then can result in a false small refault distance, leading
> 
> "which can then can" - please remove one of the "can".

Good catch, will fix.

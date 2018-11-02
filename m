Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E289A6B0005
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 11:25:21 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id a1-v6so801943ljk.7
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 08:25:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7-v6sor21210087ljk.15.2018.11.02.08.25.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 08:25:20 -0700 (PDT)
Date: Fri, 2 Nov 2018 18:25:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mremap: properly flush TLB before releasing the page
Message-ID: <20181102152516.dkqpeubxh6c3phl2@kshutemo-mobl1>
References: <1541164962-28533-1-git-send-email-will.deacon@arm.com>
 <20181102145638.gehn7eszv22lelh6@kshutemo-mobl1>
 <CAG48ez38PmTKPq_UQ4q39bwtWmb7epyet3-iSvt5b7JfwmCniw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez38PmTKPq_UQ4q39bwtWmb7epyet3-iSvt5b7JfwmCniw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 02, 2018 at 04:00:17PM +0100, Jann Horn wrote:
> On Fri, Nov 2, 2018 at 3:56 PM Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Fri, Nov 02, 2018 at 01:22:42PM +0000, Will Deacon wrote:
> > > From: Linus Torvalds <torvalds@linux-foundation.org>
> > >
> > > Commit eb66ae030829605d61fbef1909ce310e29f78821 upstream.
> >
> > I have never seen the original patch on mailing lists, so I'll reply to
> > the backport.
> 
> For context, the original bug report is public at
> https://bugs.chromium.org/p/project-zero/issues/detail?id=1695 .

Okay. I see.

I wounder if it would be cheaper to fix this by taking i_mmap_lock_write()
unconditionally in mremap() path rather than do a lot of flushing.
We take the lock now only to remap to lower addresses.

-- 
 Kirill A. Shutemov

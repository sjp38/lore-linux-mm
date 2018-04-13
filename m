Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0630B6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:04:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x184so4967569pfd.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:04:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si283205pgv.661.2018.04.13.09.04.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 09:04:37 -0700 (PDT)
Date: Fri, 13 Apr 2018 18:04:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
Message-ID: <20180413160435.GA17484@dhcp22.suse.cz>
References: <20180412153941.170849-1-jannh@google.com>
 <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
 <CAKgNAkgcJ2kCTff0=7=D3zPFwpJt-9EM8yis6-4qDjfvvb8ukw@mail.gmail.com>
 <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com>
 <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com>
 <CAG48ez085cASur3kZTRkdJY20dFZ4Yqc1KVOHxnCAn58_NtW8w@mail.gmail.com>
 <cfbbbe06-5e63-e43c-fb28-c5afef9e1e1d@nvidia.com>
 <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz>
 <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Fri 13-04-18 17:04:09, Jann Horn wrote:
> On Fri, Apr 13, 2018 at 8:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 13-04-18 08:43:27, Michael Kerrisk wrote:
> > [...]
> >> So, you mean remove this entire paragraph:
> >>
> >>               For cases in which the specified memory region has not been
> >>               reserved using an existing mapping,  newer  kernels  (Linux
> >>               4.17  and later) provide an option MAP_FIXED_NOREPLACE that
> >>               should be used instead; older kernels require the caller to
> >>               use addr as a hint (without MAP_FIXED) and take appropriate
> >>               action if the kernel places the new mapping at a  different
> >>               address.
> >>
> >> It seems like some version of the first half of the paragraph is worth
> >> keeping, though, so as to point the reader in the direction of a remedy.
> >> How about replacing that text with the following:
> >>
> >>               Since  Linux 4.17, the MAP_FIXED_NOREPLACE flag can be used
> >>               in a multithreaded program to avoid  the  hazard  described
> >>               above.
> >
> > Yes, that sounds reasonable to me.
> 
> But that kind of sounds as if you can't avoid it before Linux 4.17,
> when actually, you just have to call mmap() with the address as hint,
> and if mmap() returns a different address, munmap() it and go on your
> normal error path.

This is still racy in multithreaded application which is the main point
of the whole section, no?

-- 
Michal Hocko
SUSE Labs

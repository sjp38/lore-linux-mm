Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 631FF6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 13:06:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so748313pgn.16
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 10:06:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34-v6si1532540pln.473.2018.04.11.10.06.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 10:06:42 -0700 (PDT)
Date: Wed, 11 Apr 2018 19:06:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
Message-ID: <20180411170356.GM23400@dhcp22.suse.cz>
References: <20180411120452.1736-1-mhocko@kernel.org>
 <CAG48ez3BS5EtnrhFQUGYY9MKGOUHzFbhauJQd361uTwy2pBEeg@mail.gmail.com>
 <20180411163631.GL23400@dhcp22.suse.cz>
 <CAG48ez2wYqxJEHgZCz5g6ZYBY4_qDcYWSGAErC8pUzmrW62rug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2wYqxJEHgZCz5g6ZYBY4_qDcYWSGAErC8pUzmrW62rug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 11-04-18 18:40:09, Jann Horn wrote:
> On Wed, Apr 11, 2018 at 6:36 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 11-04-18 17:37:46, Jann Horn wrote:
> >> On Wed, Apr 11, 2018 at 2:04 PM,  <mhocko@kernel.org> wrote:
> >> > From: Michal Hocko <mhocko@suse.com>
> >> >
> >> > 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
> >> > atomicaly probe for a given address range.
> >> >
> >> > [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> >> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> >> > ---
> >> > Hi,
> >> > Andrew's sent the MAP_FIXED_NOREPLACE to Linus for the upcoming merge
> >> > window. So here we go with the man page update.
> >> >
> >> >  man2/mmap.2 | 27 +++++++++++++++++++++++++++
> >> >  1 file changed, 27 insertions(+)
> >> >
> >> > diff --git a/man2/mmap.2 b/man2/mmap.2
> >> > index ea64eb8f0dcc..f702f3e4eba2 100644
> >> > --- a/man2/mmap.2
> >> > +++ b/man2/mmap.2
> >> > @@ -261,6 +261,27 @@ Examples include
> >> >  and the PAM libraries
> >> >  .UR http://www.linux-pam.org
> >> >  .UE .
> >> > +Newer kernels
> >> > +(Linux 4.17 and later) have a
> >> > +.B MAP_FIXED_NOREPLACE
> >> > +option that avoids the corruption problem; if available, MAP_FIXED_NOREPLACE
> >> > +should be preferred over MAP_FIXED.
> >>
> >> This still looks wrong to me. There are legitimate uses for MAP_FIXED,
> >> and for most users of MAP_FIXED that I'm aware of, MAP_FIXED_NOREPLACE
> >> wouldn't work while MAP_FIXED works perfectly well.
> >>
> >> MAP_FIXED is for when you have already reserved the targeted memory
> >> area using another VMA; MAP_FIXED_NOREPLACE is for when you haven't.
> >> Please don't make it sound as if MAP_FIXED is always wrong.
> >
> > Well, this was suggested by John. I think, nobody is objecting that
> > MAP_FIXED has legitimate usecases. The above text just follows up on
> > the previous section which emphasises the potential memory corruption
> > problems and it suggests that a new flag is safe with that regards.
> >
> > If you have specific wording that would be better I am open for changes.
> 
> I guess I'd probably also want to change the previous text; so I
> should probably send a followup patch once this one has landed.

yeah, that sounds like a better plan.
-- 
Michal Hocko
SUSE Labs

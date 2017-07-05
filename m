Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED24C680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 15:17:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p1so170880298pfl.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 12:17:32 -0700 (PDT)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id a12si7300249plt.90.2017.07.05.12.17.30
        for <linux-mm@kvack.org>;
        Wed, 05 Jul 2017 12:17:32 -0700 (PDT)
Date: Wed, 5 Jul 2017 21:17:25 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes
 in the stack
Message-ID: <20170705191725.GE24459@1wt.eu>
References: <20170705165602.15005-1-mhocko@kernel.org>
 <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
 <20170705182849.GA18027@dhcp22.suse.cz>
 <CA+55aFz74mtKc7FqH6WttqNbJinV199zzM1BGFPG+Y9aN445OA@mail.gmail.com>
 <20170705185302.GA24733@dhcp22.suse.cz>
 <CA+55aFwtTHcFkpB+wKQ=aFjNqsh_UX8781eDVxxJMjEPP5oatQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwtTHcFkpB+wKQ=aFjNqsh_UX8781eDVxxJMjEPP5oatQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jul 05, 2017 at 12:15:05PM -0700, Linus Torvalds wrote:
> On Wed, Jul 5, 2017 at 11:53 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > That would lead to conflicts when backporting to stable trees though
> > which is quite annoying as well and arguably slightly more annoying than
> > resolving this in mmotm. I can help to rebase Oleg's patch on top of
> > mine which is not a stable material.
> 
> Ok, fair enough - I was actually expecting that Oleg's patch would
> just be marked for stable too just to keep differences minimal.
> 
> But yes, putting your patch in first and then Oleg's on top means that
> it works regardless.
> 
> Any opinions from others?

No pb here, and this one is reasonably easy to backport anyway as the
test is easy to locate.

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

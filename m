Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 447F86B03B4
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 15:10:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r103so48837909wrb.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 12:10:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si17418631wrd.173.2017.07.05.12.10.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 12:10:10 -0700 (PDT)
Date: Wed, 5 Jul 2017 21:10:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes
 in the stack
Message-ID: <20170705191007.GA26635@dhcp22.suse.cz>
References: <20170705165602.15005-1-mhocko@kernel.org>
 <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
 <20170705182849.GA18027@dhcp22.suse.cz>
 <CA+55aFz74mtKc7FqH6WttqNbJinV199zzM1BGFPG+Y9aN445OA@mail.gmail.com>
 <20170705185302.GA24733@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705185302.GA24733@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed 05-07-17 20:53:02, Michal Hocko wrote:
> On Wed 05-07-17 11:35:51, Linus Torvalds wrote:
> > On Wed, Jul 5, 2017 at 11:28 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > Dohh, that was on mmotm which has a clean up by Oleg which reorganizes
> > > the code a bit. This is on top of the current master
> > 
> > Oh, ok. I think I know which patch from Oleg you're talking about.
> > 
> > Since I do want that patch too, and since I'd hate to cause
> > unnecessary merge conflicts in this area, how about we just plan on
> > letting your original patch (on top of Oleg's) go through Andrew and
> > the -mm tree? I'll get it that way, and it's not like this is
> > timing-critical.
> 
> That would lead to conflicts when backporting to stable trees though
> which is quite annoying as well and arguably slightly more annoying than
> resolving this in mmotm. I can help to rebase Oleg's patch on top of
> mine which is not a stable material.

Here is the rebase of Oleg's patch.
---

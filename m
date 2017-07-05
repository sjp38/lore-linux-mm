Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72AC9680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 15:15:06 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x82so36946847oix.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 12:15:06 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id p27si19249170oie.387.2017.07.05.12.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 12:15:05 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id d77so28880171oig.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 12:15:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705185302.GA24733@dhcp22.suse.cz>
References: <20170705165602.15005-1-mhocko@kernel.org> <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
 <20170705182849.GA18027@dhcp22.suse.cz> <CA+55aFz74mtKc7FqH6WttqNbJinV199zzM1BGFPG+Y9aN445OA@mail.gmail.com>
 <20170705185302.GA24733@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jul 2017 12:15:05 -0700
Message-ID: <CA+55aFwtTHcFkpB+wKQ=aFjNqsh_UX8781eDVxxJMjEPP5oatQ@mail.gmail.com>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes in
 the stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jul 5, 2017 at 11:53 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> That would lead to conflicts when backporting to stable trees though
> which is quite annoying as well and arguably slightly more annoying than
> resolving this in mmotm. I can help to rebase Oleg's patch on top of
> mine which is not a stable material.

Ok, fair enough - I was actually expecting that Oleg's patch would
just be marked for stable too just to keep differences minimal.

But yes, putting your patch in first and then Oleg's on top means that
it works regardless.

Any opinions from others?

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

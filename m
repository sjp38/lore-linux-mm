Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67888680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 14:28:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b189so30493717wmb.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 11:28:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j83si17164216wma.149.2017.07.05.11.28.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 11:28:53 -0700 (PDT)
Date: Wed, 5 Jul 2017 20:28:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes
 in the stack
Message-ID: <20170705182849.GA18027@dhcp22.suse.cz>
References: <20170705165602.15005-1-mhocko@kernel.org>
 <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed 05-07-17 10:43:27, Linus Torvalds wrote:
> On Wed, Jul 5, 2017 at 9:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > "mm: enlarge stack guard gap" has introduced a regression in some rust
> > and Java environments which are trying to implement their own stack
> > guard page.  They are punching a new MAP_FIXED mapping inside the
> > existing stack Vma.
> 
> Hmm. What version is this patch against? It doesn't seem to match my 4.12 tree.

Dohh, that was on mmotm which has a clean up by Oleg which reorganizes
the code a bit. This is on top of the current master
---

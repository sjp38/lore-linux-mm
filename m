Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id D94316B003B
	for <linux-mm@kvack.org>; Tue, 27 May 2014 12:56:47 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id a108so14239419qge.39
        for <linux-mm@kvack.org>; Tue, 27 May 2014 09:56:47 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id f6si18225348qag.75.2014.05.27.09.56.47
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 09:56:47 -0700 (PDT)
Date: Tue, 27 May 2014 11:56:44 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
In-Reply-To: <20140527164341.GD11074@laptop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.10.1405271152400.14883@gentwo.org>
References: <20140526145605.016140154@infradead.org> <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com> <20140526203232.GC5444@laptop.programming.kicks-ass.net> <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net> <alpine.DEB.2.10.1405270929550.13999@gentwo.org> <20140527144655.GC19143@laptop.programming.kicks-ass.net> <alpine.DEB.2.10.1405271011100.14466@gentwo.org> <20140527153143.GD19143@laptop.programming.kicks-ass.net>
 <alpine.DEB.2.10.1405271128530.14883@gentwo.org> <20140527164341.GD11074@laptop.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, 27 May 2014, Peter Zijlstra wrote:

> > Code could be easily added to alloc_pages_vma() to consider the pinned
> > status on allocation. Remove GFP_MOVABLE if the vma is pinned.
>
> Yes, but alloc_pages_vma() isn't used for shared pages (with exception
> of shmem and hugetlbfs).

alloc_pages_vma() is used for all paths where we populate address ranges
with pages. This is what we are doing when pinning. Pages are not
allocated outside of a vma context.

What do you mean by shared pages that are not shmem pages? AnonPages that
are referenced from multiple processes?

> So whichever way around we have to do the mm_populate() + eviction hook
> + migration code, and since that equally covers the anon case, why
> bother?

Migration is expensive and the memory registration overhead already
causes lots of complaints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

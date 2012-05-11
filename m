Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 493328D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 10:10:21 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4625115pbb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 07:10:20 -0700 (PDT)
Date: Fri, 11 May 2012 07:10:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
In-Reply-To: <4FACD00D.4060003@kernel.org>
Message-ID: <alpine.LSU.2.00.1205110656540.5839@eggly.anvils>
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils> <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com> <4FACD00D.4060003@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 11 May 2012, Minchan Kim wrote:
> On 05/11/2012 05:30 PM, Sasha Levin wrote:
> 
> >> Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
> >> mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
> >> which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
> >> us expect it to be left unset at 0 (and it's not then used as a divisor).
> > 
> > I'm a bit confused about this, does it mean that once you set
> > percpu_pagelist_fraction to a value above the minimum, you can no
> > longer set it back to being 0?
> 
> 
> Unfortunately, Yes. :(
> It's rather awkward and need fix.

It's inelegant, but does that actually need a fix?  Has anybody asked
for that option in the six years of percpu_pagelist_fraction?

Does setting percpu_pagelist_fraction to some large number perhaps
approximate to the default behaviour of percpu_pagelist_fraction 0?

I don't care very much either way - just don't want this discussion
to divert from applying last night's fix to the default behaviour
that most people expect.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

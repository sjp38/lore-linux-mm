Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C0F6B038C
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 04:08:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n6so2418225pfg.19
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 01:08:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si1640623pln.445.2017.12.06.01.08.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 01:08:08 -0800 (PST)
Date: Wed, 6 Dec 2017 10:08:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171206090803.GG16386@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <87zi6we9z2.fsf@concordia.ellerman.id.au>
 <a3b3129a-2626-a65e-59b0-68aada523723@prevas.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3b3129a-2626-a65e-59b0-68aada523723@prevas.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On Wed 06-12-17 08:33:37, Rasmus Villemoes wrote:
> On 2017-12-06 05:50, Michael Ellerman wrote:
> > Michal Hocko <mhocko@kernel.org> writes:
> > 
> >> On Wed 29-11-17 14:25:36, Kees Cook wrote:
> >> It is safe in a sense it doesn't perform any address space dangerous
> >> operations. mmap is _inherently_ about the address space so the context
> >> should be kind of clear.
> > 
> > So now you have to define what "dangerous" means.
> > 
> >>> MAP_FIXED_UNIQUE
> >>> MAP_FIXED_ONCE
> >>> MAP_FIXED_FRESH
> >>
> >> Well, I can open a poll for the best name, but none of those you are
> >> proposing sound much better to me. Yeah, naming sucks...
> 
> I also don't like the _SAFE name - MAP_FIXED in itself isn't unsafe [1],
> but I do agree that having a way to avoid clobbering (parts of) an
> existing mapping is quite useful. Since we're bikeshedding names, how
> about MAP_FIXED_EXCL, in analogy with the O_ flag.

I really give up on the name discussion. I will take whatever the
majority comes up with. I just do not want this (useful) funtionality
get bikeched to death.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 030666B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 04:03:07 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r20so9820415wrg.23
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 01:03:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c16si9963923wrb.267.2017.12.11.01.03.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 01:03:05 -0800 (PST)
Date: Mon, 11 Dec 2017 10:03:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171211090303.GG20234@dhcp22.suse.cz>
References: <20171206031434.29087-1-jhubbard@nvidia.com>
 <20171210103147.GC20234@dhcp22.suse.cz>
 <fba147b0-06b6-fbf9-8194-171a3e146a63@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fba147b0-06b6-fbf9-8194-171a3e146a63@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>

On Sun 10-12-17 18:22:05, John Hubbard wrote:
> On 12/10/2017 02:31 AM, Michal Hocko wrote:
> > On Tue 05-12-17 19:14:34, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> Previously, MAP_FIXED was "discouraged", due to portability
> >> issues with the fixed address. In fact, there are other, more
> >> serious issues. Also, alignment requirements were a bit vague.
> >> So:
> >>
> >>     -- Expand the documentation to discuss the hazards in
> >>        enough detail to allow avoiding them.
> >>
> >>     -- Mention the upcoming MAP_FIXED_SAFE flag.
> >>
> >>     -- Enhance the alignment requirement slightly.
> >>
> >> Some of the wording is lifted from Matthew Wilcox's review
> >> (the "Portability issues" section). The alignment requirements
> >> section uses Cyril Hrubis' wording, with light editing applied.
> >>
> >> Suggested-by: Matthew Wilcox <willy@infradead.org>
> >> Suggested-by: Cyril Hrubis <chrubis@suse.cz>
> >> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > 
> > Would you mind if I take this patch and resubmit it along with my
> > MAP_FIXED_SAFE (or whatever name I will end up with) next week?
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Sure, that works for me. A tiny complication: I see that Michael
> Kerrisk has already applied the much smaller v2 of this patch (the
> one that "no longer discourages" the option, but that's all), as:
> 
>    ffa518803e14 mmap.2: MAP_FIXED is no longer discouraged
> 
> so this one here will need to be adjusted slightly to merge
> gracefully. Let me know if you want me to respin, or if you
> want to handle the merge.

Yes, please respin.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

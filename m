Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 025386B0282
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 07:27:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so44773811wme.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:27:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si26416668wme.37.2017.01.26.04.27.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 04:27:33 -0800 (PST)
Date: Thu, 26 Jan 2017 13:27:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126122729.GL6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <20170126103216.GG6590@dhcp22.suse.cz>
 <1485432877.12563.100.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485432877.12563.100.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 04:14:37, Joe Perches wrote:
> On Thu, 2017-01-26 at 11:32 +0100, Michal Hocko wrote:
> > So I have folded the following to the patch 1. It is in line with
> > kvmalloc and hopefully at least tell more than the current code.
> []
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> []
> > @@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> >   *	Allocate enough pages to cover @size from the page level
> >   *	allocator with @gfp_mask flags.  Map them into contiguous
> >   *	kernel virtual space, using a pagetable protection of @prot.
> > + *
> > + *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
> > + *	and __GFP_NOFAIL are not supported
> 
> Maybe add a BUILD_BUG or a WARN_ON_ONCE to catch new occurrences?

I would really like to not touch vmalloc in this series.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48DCD6B0268
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 07:14:41 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f9so180227267otd.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:14:41 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTPS id j127si1687801itj.118.2017.01.26.04.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 04:14:40 -0800 (PST)
Message-ID: <1485432877.12563.100.camel@perches.com>
Subject: Re: [PATCH 0/6 v3] kvmalloc
From: Joe Perches <joe@perches.com>
Date: Thu, 26 Jan 2017 04:14:37 -0800
In-Reply-To: <20170126103216.GG6590@dhcp22.suse.cz>
References: 
	<CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
	 <588907AA.1020704@iogearbox.net> <20170126074354.GB8456@dhcp22.suse.cz>
	 <5889C331.7020101@iogearbox.net> <20170126100802.GF6590@dhcp22.suse.cz>
	 <20170126103216.GG6590@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu, 2017-01-26 at 11:32 +0100, Michal Hocko wrote:
> So I have folded the following to the patch 1. It is in line with
> kvmalloc and hopefully at least tell more than the current code.
[]
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
[]
> @@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>   *	Allocate enough pages to cover @size from the page level
>   *	allocator with @gfp_mask flags.  Map them into contiguous
>   *	kernel virtual space, using a pagetable protection of @prot.
> + *
> + *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
> + *	and __GFP_NOFAIL are not supported

Maybe add a BUILD_BUG or a WARN_ON_ONCE to catch new occurrences?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

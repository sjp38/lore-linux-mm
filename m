Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A38B6B000C
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:17:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r16-v6so4098068pgv.17
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 16:17:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r28-v6si6192319pgb.444.2018.10.24.16.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 16:17:56 -0700 (PDT)
Date: Wed, 24 Oct 2018 16:17:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into
 alloc_hugepage_direct_gfpmask
Message-Id: <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org>
In-Reply-To: <583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
	<20180925120326.24392-3-mhocko@kernel.org>
	<20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1>
	<20180926141708.GX6278@dhcp22.suse.cz>
	<20180926142227.GZ6278@dhcp22.suse.cz>
	<20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org>
	<20181019080657.GJ18839@dhcp22.suse.cz>
	<583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 22 Oct 2018 15:27:54 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> > : Moreover the oriinal code allowed to trigger
> > : 	WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> > : in policy_node if the requested node (e.g. cpu local one) was outside of
> > : the mbind nodemask. This is not possible now. We haven't heard about any
> > : such warning yet so it is unlikely that it happens but still a signal of
> > : a wrong code layering.
> 
> Ah, as I said in the other mail, I think it's inaccurate, the warning
> was not possible to hit.
> 
> There's also a slight difference wrt MPOL_BIND. The previous code would
> avoid using __GFP_THISNODE if the local node was outside of
> policy_nodemask(). After your patch __GFP_THISNODE is avoided for all
> MPOL_BIND policies. So there's a difference that if local node is
> actually allowed by the bind policy's nodemask, previously
> __GFP_THISNODE would be added, but now it won't be. I don't think it
> matters that much though, but maybe the changelog could say that
> (instead of the inaccurate note about warning). Note the other policy
> where nodemask is relevant is MPOL_INTERLEAVE, and that's unchanged by
> this patch.

So the above could go into the changelog, yes?

> When that's addressed, you can add

What is it that you'd like to see addressed?  Purely changelog updates?

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

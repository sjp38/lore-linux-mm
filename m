Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF100C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8B2120820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:06:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uWscbpyE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8B2120820
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47AC96B0005; Thu,  5 Sep 2019 17:06:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42AC46B0007; Thu,  5 Sep 2019 17:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319576B0008; Thu,  5 Sep 2019 17:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0D96B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:06:32 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6F9AF3D13
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:06:31 +0000 (UTC)
X-FDA: 75902100582.20.scarf44_55f912a9b3c62
X-HE-Tag: scarf44_55f912a9b3c62
X-Filterd-Recvd-Size: 5861
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:06:30 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id t1so1939703plq.13
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:06:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=7yHi0EM1wuHkGMUXZfyVx9tlNjiQXCUzsYhxBeDzV1M=;
        b=uWscbpyE9dkQ9Ap1if0mlmhhmk+R0k97L94OzwSIXUqJELkO2/2TXzdywhKxRhbVlM
         9nwWPY2AnphlO1rv6bfaXnbTsHQoDyVbXGQkoyPgHItxjjrbsxyVWoxa6PWitoOp1dRQ
         mcru8jMKrYMsWTsxlkeThn8Vt0wCPRJtXu4Pj3pCU7kQvweSrePlGfJYKYP1XlDxdwGU
         Z9jYHkXY7bmjqSEBTwdCT8DkDU/P+7lO6GWUMv9NyV+FzO1a5L63v5OLaLzmut9ies48
         PPkZ7WhKCD1a4BMC8aJ3SlOFbGfeKBztSD+oD+KW7Cqx1c1OgaRKyq7oj1dxxRTM1IhT
         eRLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=7yHi0EM1wuHkGMUXZfyVx9tlNjiQXCUzsYhxBeDzV1M=;
        b=M/KLPXzejXV7k5G6qsICx99APFYPz25xGg8sSYQQ+/1FgZq8kS09IQW+KCkVqcnkUO
         eNLsE9tSDpXUAxI0kAETLgD7ovei7yF5jx5Te4IjBl5IB8jE2Wl1fNcd51SRxRFkA7Qx
         obxRLpif1sY2jvKMyff6usLcBGW4VuNP9C6hC59o4SO/Fjb8GP0toIxSjdvsznwQoQmX
         reJytbGG0wT/m9V2fJ+YS0RMfI0Mp4w8REraigfKzZIgDJnMZU7T3kkDsQ0O7bz532wY
         piORyq8JOlPbKJu1Yc1BjyiJyFZuyQI/aTS+nxTXEvFwtfviADLhWowfYyBDEzkD4t27
         91Mg==
X-Gm-Message-State: APjAAAX1HVCojuCA4JBb0GYs3jnDhoRdlQy9VQqLl9ilHM2/u59+THqn
	SvrkHeCLl1pz+x+5UmDNgU5QBA==
X-Google-Smtp-Source: APXvYqxa3O1y+UYUcg/sw8NEN3sLIDwiUwCYusviqLqWksc3bVLb0LBFDZQNKLHASvtiUEQWkO6DDw==
X-Received: by 2002:a17:902:8f95:: with SMTP id z21mr5759919plo.42.1567717589379;
        Thu, 05 Sep 2019 14:06:29 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id c14sm3832157pfo.64.2019.09.05.14.06.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 14:06:28 -0700 (PDT)
Date: Thu, 5 Sep 2019 14:06:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrea Arcangeli <aarcange@redhat.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote
 hugepages
In-Reply-To: <20190904205522.GA9871@redhat.com>
Message-ID: <alpine.DEB.2.21.1909051400380.217933@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com> <20190904205522.GA9871@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019, Andrea Arcangeli wrote:

> > This is an admittedly hacky solution that shouldn't cause anybody to 
> > regress based on NUMA and the semantics of MADV_HUGEPAGE for the past 
> > 4 1/2 years for users whose workload does fit within a socket.
> 
> How can you live with the below if you can't live with 5.3-rc6? Here
> you allocate remote THP if the local THP allocation fails.
> 
> >  			page = __alloc_pages_node(hpage_node,
> >  						gfp | __GFP_THISNODE, order);
> > +
> > +			/*
> > +			 * If hugepage allocations are configured to always
> > +			 * synchronous compact or the vma has been madvised
> > +			 * to prefer hugepage backing, retry allowing remote
> > +			 * memory as well.
> > +			 */
> > +			if (!page && (gfp & __GFP_DIRECT_RECLAIM))
> > +				page = __alloc_pages_node(hpage_node,
> > +						gfp | __GFP_NORETRY, order);
> > +
> 
> You're still going to get THP allocate remote _before_ you have a
> chance to allocate 4k local this way. __GFP_NORETRY won't make any
> difference when there's THP immediately available in the remote nodes.
> 

This is incorrect: the fallback allocation here is only if the initial 
allocation with __GFP_THISNODE fails.  In that case, we were able to 
compact memory to make a local hugepage available without incurring 
excessive swap based on the RFC patch that appears as patch 3 in this 
series.  I very much believe your usecase would benefit from this as well 
(or at least not cause others to regress).  We *want* remote thp if they 
are immediately available but only after we have tried to allocate locally 
from the initial allocation and allowed memory compaction fail first.

Likely there can be discussion around the fourth patch of this series to 
get exactly the right policy.  We can construct it as necessary for 
hugetlbfs to not have any change in behavior, that's simple.  We could 
also check per-zone watermarks in mm/huge_memory.c to determine if local 
memory is low-on-memory and, if so, allow remote allocation.  In that case 
it's certainly better to allocate remotely when we'd be reclaiming locally 
even for fallback native pages.

> I said one good thing about this patch series, that it fixes the swap
> storms. But upstream 5.3 fixes the swap storms too and what you sent
> is not nearly equivalent to the mempolicy that Michal was willing
> to provide you and that we thought you needed to get bigger guarantees
> of getting only local 2m or local 4k pages.
> 

I haven't seen such a patch series, is there a link?


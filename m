Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60AD3C28EB7
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:12:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15EB920868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:12:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mouT5fX9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15EB920868
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16216B02F3; Thu,  6 Jun 2019 18:12:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C6096B02F4; Thu,  6 Jun 2019 18:12:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B41E6B02F5; Thu,  6 Jun 2019 18:12:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 542786B02F3
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:12:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k23so2499836pgh.10
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:12:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=I1d4jIEuRlGZxg1GucXllJmBFZyMym/U3WNCfHVcLJQ=;
        b=hdKxFtjrCq92QSgkWEofdueqq4/oSjva8cmYgQSpyWzTNHsR2XFXbRmfLOdogOL4dl
         ZMeDBwZgTBAW3VOKgI5PRuMAAJErKqpO5sddG34SNOnRRqof8nNl53I8xNpZRfyzW1xT
         uB7WXMkaqWV2HaDDrhs5FcG86BoyhJ2I+anvGBIqImGSg5o5uVT72w1ePMThx8j7v9nj
         cLwYQDF3VZw54A1WCO4cH65tMyXwEsrLNTPup+9rG8B1enVw9aIfvHdCwNeVJMq/lBMn
         FFkJl3vPywPd/aBxCyIT8aDqVFAOnBV40pXDcGTE+SEMszKbP7SQ6tMcLKPcnDi0H9Nt
         RFJw==
X-Gm-Message-State: APjAAAUwb7uQ/JTVmpP0FN8QpGhybYT76bAZWoUmCVigt9CZBkXJ+0iY
	KRnThmi81z0TFrU7iEu3qtVY3qN4vIH7z2hmveGHIaiPGr4wvKGLJsMGFigBBB0fyR18EBT4+pO
	DCijrwWsGwaju21pINJ5OWL4chWm/w6FQYKzPgatLqDVy8/wMo0h1DI97cSG/BVggBQ==
X-Received: by 2002:a17:90a:9306:: with SMTP id p6mr2035711pjo.6.1559859164892;
        Thu, 06 Jun 2019 15:12:44 -0700 (PDT)
X-Received: by 2002:a17:90a:9306:: with SMTP id p6mr2035630pjo.6.1559859163608;
        Thu, 06 Jun 2019 15:12:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559859163; cv=none;
        d=google.com; s=arc-20160816;
        b=vUq0Npv0Qqrz7trf8s67c9X0v2NiUkP97zuho6RsSd68oIySv2knAZO72oSbPZW0tf
         X2Z3ROzBmeuTHl5ete4RnjpFRvBP2XhNYTTY2L9zMYrD6lhES43mCW4ETSkMEhLmv/gR
         Bw5ieP2NrjqAGR09YhcEXiwC3XlktbRiEgcPsAwnBcZu+ze5FHiQTvyDsXojsQK7vQuD
         AUtlWHWESapPlhRnSg9rQeSrO/tDc5SpiEgxtXRalzc7CI+b8A1ES4eTKM+pnpNikNMn
         I00ry7MJUSS2l1H9rHju8cbku2+5jx8WPHJk67dBOHvtP67QaZs33kGUPl+1qJ+rTKAP
         tUXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=I1d4jIEuRlGZxg1GucXllJmBFZyMym/U3WNCfHVcLJQ=;
        b=JXCBnSrONZ6pg/tkBDk7/10tHZteW0LbXhgyPMYq0TM61meyltoNWm5yoPgBoRyLeA
         O6OluPvcNKF9TGfgZfFYTKx74pdpNJ2Lq27Ie6dPTYbYtAty9z4dvZWZEw0NAw+ZfHyF
         kTLAtfhiyiIIZyphRuV0oGyBZ+iUh/7BACYXpgCjntpHWS8MCYnTj/OHmdqm0YazAUoR
         I1dOZeymIGGmtDqt+H+B5coXlNYw3iwIdfGG2oCWMa8IzTLHkD3XeQfxXGIfJgWuB6oT
         PtszZKRZpapAApyw//VF774hGXu+26blC+YD5h34WG06OdJzh1l/yq9BkKAAAE0ChdYG
         XMQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mouT5fX9;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k13sor268977pfi.31.2019.06.06.15.12.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 15:12:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mouT5fX9;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=I1d4jIEuRlGZxg1GucXllJmBFZyMym/U3WNCfHVcLJQ=;
        b=mouT5fX9PGtJtroNBzXumdz4FHH4ysx4UiwDXX9RCT9ZI3lMJ0dTVWDhkhLgW3ap12
         yFzqZyKUc9zy3b/vCzYL1ERNGlywnytPiP48/2c9D5amdBMrK6O1KpFPlVpWrmaBmJbH
         1wEurHk3gdYBVqupABQu7ZW8gdEASp7obEPFyZ8QC3hhj3sKKFwKNONMjyIQDzSjt7yt
         bbpLFqKtu2/duZmtdL+o91cVCsWb88L+Okv3evlKYHC/zW+YP67ke1dso3WO8FHLLkj6
         cuTq8TpWl4B2V8XMOukRykCXTalM33NB14xrrhS0YBlEpHmdg9DrBtk9Lua/6YqZUnJf
         Zcnw==
X-Google-Smtp-Source: APXvYqwQnBorcRjflE1meuxbdMbSQ3Lv7HK4SDilnevNLs4xGX0Evf4QJigqDA0NP8G5rzuR40fmOA==
X-Received: by 2002:aa7:8b12:: with SMTP id f18mr54779859pfd.178.1559859162875;
        Thu, 06 Jun 2019 15:12:42 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id c6sm148687pfm.163.2019.06.06.15.12.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 06 Jun 2019 15:12:41 -0700 (PDT)
Date: Thu, 6 Jun 2019 15:12:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Michal Hocko <mhocko@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, 
    Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, 
    Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <20190605093257.GC15685@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1906061451001.121338@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net> <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org> <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com> <20190531092236.GM6896@dhcp22.suse.cz> <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com>
 <20190605093257.GC15685@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jun 2019, Michal Hocko wrote:

> > That's fine, but we also must be mindful of users who have used 
> > MADV_HUGEPAGE over the past four years based on its hard-coded behavior 
> > that would now regress as a result.
> 
> Absolutely, I am all for helping those usecases. First of all we need to
> understand what those usecases are though. So far we have only seen very
> vague claims about artificial worst case examples when a remote access
> dominates the overall cost but that doesn't seem to be the case in real
> life in my experience (e.g. numa balancing will correct things or the
> over aggressive node reclaim tends to cause problems elsewhere etc.).
> 

The usecase is a remap of a binary's text segment to transparent hugepages 
by doing mmap() -> madvise(MADV_HUGEPAGE) -> mremap() and when this 
happens on a locally fragmented node.  This happens at startup when we 
aren't concerned about allocation latency: we want to compact.  We are 
concerned with access latency thereafter as long as the process is 
running.

MADV_HUGEPAGE has worked great for this and we have a large userspace 
stack built upon that because it's been the long-standing behavior.  This 
gets back to the point of MADV_HUGEPAGE being overloaded for four 
different purposes.  I argue that processes that fit within a single node 
are in the majority.

> > Thus far, I haven't seen anybody engage in discussion on how to address 
> > the issue other than proposed reverts that readily acknowledge they cause 
> > other users to regress.  If all nodes are fragmented, the swap storms that 
> > are currently reported for the local node would be made worse by the 
> > revert -- if remote hugepages cannot be faulted quickly then it's only 
> > compounded the problem.
> 
> Andrea has outline the strategy to go IIRC. There also has been a
> general agreement that we shouldn't be over eager to fall back to remote
> nodes if the base page size allocation could be satisfied from a local node.

Sorry, I haven't seen patches for this, I can certainly test them if 
there's a link.  If we have the ability to tune how eager the page 
allocator is to fallback and have the option to say "never" as part of 
that eagerness, it may work.

The idea that I had was snipped from this, however, and it would be nice 
to get some feedback on it: I've suggested that direct reclaim for the 
purposes of hugepage allocation on the local node is never worthwhile 
unless and until memory compaction can both capture that page to use (not 
rely on the freeing scanner to find it) and that migration of a number of 
pages would eventually result in the ability to free a pageblock.

I'm hoping that we can all agree to that because otherwise it leads us 
down a bad road if reclaim is doing pointless work (freeing scanner can't 
find it or it gets allocated again before it can find it) or compaction 
can't make progress as a result of it (even though we can migrate, it 
still won't free a pageblock).

In the interim, I think we should suppress direct reclaim entirely for 
thp allocations, regardless of enabled=always or MADV_HUGEPAGE because it 
cannot be proven that the reclaim work is beneficial and I believe it 
results in the swap storms that are being reported.

Any disagreements so far?

Furthermore, if we can agree to that, memory compaction when allocating a 
transparent hugepage fails for different reasons, one of which is because 
we fail watermark checks because we lack migration targets.  This is 
normally what leads to direct reclaim.  Compaction is *supposed* to return 
COMPACT_SKIPPED for this but that's overloaded as well: it happens when we 
fail extfrag_threshold checks and wheng gfp flags doesn't allow it.  The 
former matters for thp.

So my proposed change would be:
 - give the page allocator a consistent indicator that compaction failed
   because we are low on memory (make COMPACT_SKIPPED really mean this),
 - if we get this in the page allocator and we are allocating thp, fail,
   reclaim is unlikely to help here and is much more likely to be
   disruptive
     - we could retry compaction if we haven't scanned all memory and
       were contended,
 - if the hugepage allocation fails, have thp check watermarks for order-0 
   pages without any padding,
 - if watermarks succeed, fail the thp allocation: we can't allocate
   because of fragmentation and it's better to return node local memory,
 - if watermarks fail, a follow up allocation of the pte will likely also
   fail, so thp retries the allocation with a cleared  __GFP_THISNODE.

This doesn't sound very invasive and I'll code it up if it will be tested.


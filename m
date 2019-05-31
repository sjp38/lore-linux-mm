Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83667C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F2F926F79
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:53:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bdjWp/ki"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F2F926F79
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B09076B0005; Fri, 31 May 2019 17:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB9D76B026A; Fri, 31 May 2019 17:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CED16B026B; Fri, 31 May 2019 17:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 639866B0005
	for <linux-mm@kvack.org>; Fri, 31 May 2019 17:53:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so8392332pfo.13
        for <linux-mm@kvack.org>; Fri, 31 May 2019 14:53:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=vkQlzDYXQfdlyaR7cXRKh8gwxLwxcbwPkOEJ9vq2Omw=;
        b=BPCR1W8F75sEMhSc0YOvZVKApqUXMifnZxM06OFQznx7q5L5ZC311V8xXmvrLsvkzy
         QUN3DefpPXE4OE8uVshVY6qSw3VSktaJ2V0YoNu7gp3vdx4wbANN1+JpSmxEI85MJVr1
         bJ1DZJjxzx77Vom0hy573xb8m4N2fMbyo+LB3XqDk9NctLXHRSkHZ/K2Mbn4kabcjUUz
         r1yEFuKRFKkNwKnf2uqdHeysigleN7Cbj5G8okQ94CWE4ej3xjJ+0NQo1zlYYI3swSZs
         jhL+ObHP5q31EGE+nD16vilEAQ6PJUpVYLh0tXCfpzxdbj7fvX/UtdUlC91X8GzHMBrs
         txsg==
X-Gm-Message-State: APjAAAWs/d8X5pDOX3f4NeRuB8i5RHAnSQkrBTX/9/JwQff1bxLpUb0p
	UcwoxLjognjlyBBKI1kvG1J3LF2l72dCiT5+t6tBJCp0h05ZP7w2fYmqvFZEr8cSFa67iHEBz8y
	MZI/AC0+zEZPu8RXRitmTzZpLzExI/kI5CQji8RZmDxq92zeBJBk0ex8G6s5/PQEA+Q==
X-Received: by 2002:a62:ed1a:: with SMTP id u26mr13072013pfh.229.1559339619982;
        Fri, 31 May 2019 14:53:39 -0700 (PDT)
X-Received: by 2002:a62:ed1a:: with SMTP id u26mr13071905pfh.229.1559339618684;
        Fri, 31 May 2019 14:53:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559339618; cv=none;
        d=google.com; s=arc-20160816;
        b=pmVVbqFWX9y97pJza8EiaDace/MsVrfQlBcnvNEWkvy04648hNrU+4Vsub5p5zNj7k
         avBvaswTVss0UJcDq+XF+StL2bjbOh5VitD1yfK7Acaxd9EfjPMvNrYS3PNSPEY/Rj5z
         aumm1x5BW6erriIi8+/bo6Lgpkotz0wlcNmkOZxb7RMWYHMVWCULOlmctybVj0Eho3nc
         TrbjigIeDkI0iyDGU20b5/g4/Ex7+OcFicRdFxhics2pbAWldF19+aFV/M0H8BUOzONq
         l81zkA/NYsaifyqabk8gaWo4PcFbAXksWIS8pKj84FGsPYRC7P5r3MyFWreVmT3hLRqx
         klbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=vkQlzDYXQfdlyaR7cXRKh8gwxLwxcbwPkOEJ9vq2Omw=;
        b=Cqq7ScvYIjSdZp14wZe6fqz2SR9+x4I0ZSg+LUX97fDhXjJgG+ag31ujMwybUSusuF
         MVawTyRBB0QVRPq4rwpTaZHQ4SQiqftnrXo+tfE6EM2p2nXMn9Usp1n29DjQo6NDSykg
         hGNo4QTxoDmYMtKtQU/WBYbCuPClpoAxA67n2EwptxMVI4qFC5tGOdmAxbcU6l4tShUO
         OI45QQXd4sRBoDbX1d38FDDx4TFmmmlaprNjln4819IGpqslB5Awn8WkqLXvllk6k9x+
         qlThzZG0rLC33xhEn0fRAJVwJ0MUDh7tGva6jDkfv3oD0z6UHeU64A+i9xol3VE8enR+
         kjbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="bdjWp/ki";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37sor8348327pla.2.2019.05.31.14.53.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 14:53:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="bdjWp/ki";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=vkQlzDYXQfdlyaR7cXRKh8gwxLwxcbwPkOEJ9vq2Omw=;
        b=bdjWp/kiI8K61vLYJBNVyXD1yeRzAm4c/wU9YQtJWhHmI8leAG9bCnI91R0z7T0tHX
         GCyr3CgTdhkf4ZV0AY4Sz3NmS/0hXLzi/1oZhKXNyuhgaySUzZBJ1VTJXPTJ18GzFJ30
         10nxiGkYjq05vLmbERivCyrBl6cf6LOEvSRM4mgS89cXN3G+3T2kmb1HRnKqpBrWW3A8
         GxmWxVsR5GJHVAjmPaZ5Lusg/iJ0NFkK7y8s9yEpN4RcPSUcx9mzJYe3eCdwDY8mPrPH
         OfnbL46FwfeAzooJcCsROwAT0aHyYJMi3mUNJGP+fFAC9RlPLEj9OKzIbm5ifj39NFyg
         Qrug==
X-Google-Smtp-Source: APXvYqxYVmQOSY28vQy91Z6Gv+2Wri+vDWxcTNI4gXySvvI3CViUkGjCkCpWvTLvqaaDYXQQ/VXHeg==
X-Received: by 2002:a17:902:2ba9:: with SMTP id l38mr5596385plb.300.1559339617730;
        Fri, 31 May 2019 14:53:37 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id e123sm6685235pgc.29.2019.05.31.14.53.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 May 2019 14:53:35 -0700 (PDT)
Date: Fri, 31 May 2019 14:53:35 -0700 (PDT)
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
In-Reply-To: <20190531092236.GM6896@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net> <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org> <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com> <20190531092236.GM6896@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 May 2019, Michal Hocko wrote:

> > The problem which this patch addresses has apparently gone unreported for 
> > 4+ years since
> 
> Can we finaly stop considering the time and focus on the what is the
> most reasonable behavior in general case please? Conserving mistakes
> based on an argument that we have them for many years is just not
> productive. It is very well possible that workloads that suffer from
> this simply run on older distribution kernels which are moving towards
> newer kernels very slowly.
> 

That's fine, but we also must be mindful of users who have used 
MADV_HUGEPAGE over the past four years based on its hard-coded behavior 
that would now regress as a result.

> > commit 077fcf116c8c2bd7ee9487b645aa3b50368db7e1
> > Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Date:   Wed Feb 11 15:27:12 2015 -0800
> > 
> >     mm/thp: allocate transparent hugepages on local node
> 
> Let me quote the commit message to the full lenght
> "
>     This make sure that we try to allocate hugepages from local node if
>     allowed by mempolicy.  If we can't, we fallback to small page allocation
>     based on mempolicy.  This is based on the observation that allocating
>     pages on local node is more beneficial than allocating hugepages on remote
>     node.
> 
>     With this patch applied we may find transparent huge page allocation
>     failures if the current node doesn't have enough freee hugepages.  Before
>     this patch such failures result in us retrying the allocation on other
>     nodes in the numa node mask.
> "
> 
> I do not see any single numbers backing those claims or any mention of a
> workload that would benefit from the change. Besides that, we have seen
> that THP on a remote (but close) node might be performing better per
> Andrea's numbers. So those claims do not apply in general.
> 

I confirm that on every platform I have tested that the access latency to 
local pages of the native page size has been less than hugepages on any 
remote node.  I think it's generally accepted that NUMA-ness is more 
important than huge-ness in terms of access latency and this is not the 
reason why the revert is being proposed.  Certainly if the argument is to 
be made that the default behavior should be what is in the best interest 
of Linux users in totality, preferring remote hugepages over local pages 
of the native page size would not be anywhere close.  I agree with 
Aneesh's commit message 100%.

> > My goal is to reach a solution that does not cause anybody to incur 
> > performance penalties as a result of it.
> 
> That is certainly appreciated and I can offer my help there as well. But
> I believe we should start with a code base that cannot generate a
> swapping storm by a trivial code as demonstrated by Mel. A general idea
> on how to approve the situation has been already outlined for a default
> case and a new memory policy has been mentioned as well but we need
> something to start with and neither of the two is compatible with the
> __GFP_THISNODE behavior.
> 

Thus far, I haven't seen anybody engage in discussion on how to address 
the issue other than proposed reverts that readily acknowledge they cause 
other users to regress.  If all nodes are fragmented, the swap storms that 
are currently reported for the local node would be made worse by the 
revert -- if remote hugepages cannot be faulted quickly then it's only 
compounded the problem.

The hugepage aware mempolicy idea is one way that could describe what 
should be done for these allocations, we could also perhaps consider 
heuristics that consider the memory pressure of the local node: just as 
I've never seen a platform where remote hugepages have better access 
latency than local pages, I've never seen a platform where remote 
hugepages aren't a win over remote pages.  This, however, is more delicate 
on 4 socket and 8 socket platforms but I think a general rule that a 
hugepage is better, if readily allocatable, than a page on the same node.  
(I've seen cross socket latency for hugepages match the latency for pages, 
so not always a win: better to leave the hugepage available remotely for 
something running on that node.)  If the local node has a workingset that 
reaches its capacity, then it makes sense to fault a remote hugepage 
instead because otherwise we are thrashing the local node.

That's not a compaction problem, though, it's a reclaim problem.  If 
compaction fails and it's because we can't allocate target pages, it's 
under memory pressure and it's uncertain if reclaim will help: it may fail 
after expensive swap, the reclaimed pages could be grabbed by somebody 
else and we loop, or the compaction freeing scanner can't find it.  Worst 
case is we thrash the local node in a swap storm.  So the argument I've 
made when the removal of __GFP_THISNODE was first proposed is that local 
hugepage allocation should be the preference including direct compaction 
for users of MADV_HUGEPAGE (or thp enabled=always) but reclaim should 
never be done locally.  I'd very much like to engage with anybody who 
would be willing to discuss fixes that work for everybody rather than only 
propose reverts and leave others to deal with new performance regressions.


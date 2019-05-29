Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36940C04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:07:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2C4E20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tyrAmgJz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2C4E20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5660B6B0272; Tue, 28 May 2019 22:07:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 516E36B0276; Tue, 28 May 2019 22:07:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4069C6B027F; Tue, 28 May 2019 22:07:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01EA86B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 22:07:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g11so452160plt.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 19:07:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=k/uph6k0VSxFUt6vW23NqyCeXeXQzEMPpEsp1IyAYdM=;
        b=SOnoKaCRb44aOR3q/gbb1cZ78jkUrgLKGuDkbvMjMpskv0/gRitLiTdFdrwlTLtfHz
         wGCTWQJGqVnueSS+T+9LqsgicBCRNgSgawe5XFx6knipkYVHLueaV2QJAzQ6vJ1sZGCY
         axKv6Uo4pyEZmeGn3h2VmcBSPox0oMJCvNsd6LOVERFVX6naIO1PmesZmqBD6JZQI+bK
         1dn/C2qzYtHscq9Cv36SixNOq3TlQmG0nSoXpQKj53d4rYcxBKF4WcU5H7WNBsUFoN24
         UOoAs0+4JwQEbq8tkXSW/6ObPRts0PUffVxz1k/1KYfb5hrdW3/vq8znI4zo1/iJ8IAo
         35sQ==
X-Gm-Message-State: APjAAAXKlv7M+K8gva0pc3g97TbtCXXttY7q3jpWzzTbFNlTxTrMZEbs
	isFCt/fk9OSLBwqib8WhVnCcR5H6DCmgnuqC9zUch620tgNS5wjmeB491x2EKpHCtpb1imRWMKv
	fGbUjktga8yEy8u3uNf+wQGZcIX3kl32c4sjmmLwKP+/lGfCUVORBjU2PRr3V0N8ZYg==
X-Received: by 2002:aa7:82d6:: with SMTP id f22mr109677pfn.151.1559095626474;
        Tue, 28 May 2019 19:07:06 -0700 (PDT)
X-Received: by 2002:aa7:82d6:: with SMTP id f22mr109615pfn.151.1559095625394;
        Tue, 28 May 2019 19:07:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559095625; cv=none;
        d=google.com; s=arc-20160816;
        b=Bj9q5oGzecTtUl8QRrVAM3XsWciOCY1QiqtVHHUZ0W9vyNwFZCmKO1awxPsSWTNauI
         eq34IOaq66Ie/l8Dv8SKHE6uQINJFlHWf7Q5a8Nyl/yVxin5TU1OblvatNyQBeiPRapa
         i8lhTxbbvarAgwMeZ3ofUDLPVLzC47lgGsVbpxc5uuntfqkOB50N5X3UgKPvL8gcVcgj
         BgHedeZ+kdJ2MH41evbj7gZSPtibBOXviz6TqUzPzfJYgBnrnA+oLH23PGuZ2oOf44dP
         SnicqjnxnJ1EuonBINYiWQ1ukaG8JBEwXrpcl332dymX4MJD2DieZ9T/yfk2z3U1graP
         G+8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=k/uph6k0VSxFUt6vW23NqyCeXeXQzEMPpEsp1IyAYdM=;
        b=Kz3L6HlfbEhZj5xb7ihBFgYvpWEyessZY7cwlmxQGLZex3cxDXy0sOV5v8yDzixsLN
         Nnc3cdgcPCQDT4JwvUbs2iUqVCsPONQaxwhSYFs8WsW3mlpMqSPCtanor9IkzHZUCGKG
         f4TgccKmxcjwbzW3quVQrm7CR0UwAVM0GVthecVvGiaoGM7qg+kJr4sA0fVhhg55YJ7Y
         b+8oipjMK5+VTZ5+TB8yeJnFNhXI+tuIT8a62tPYq0r5n539nqxaiNGdyDABy3cbqOjB
         eGlrXOJ9LLByc8vAbhCwRIBAqaGbbIGxuIK4M3t0sODIixHMdVow8cqu2XfsB1YILIw/
         Lhvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tyrAmgJz;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor19627082ple.15.2019.05.28.19.07.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 19:07:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tyrAmgJz;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=k/uph6k0VSxFUt6vW23NqyCeXeXQzEMPpEsp1IyAYdM=;
        b=tyrAmgJzpZqcjc3vBI1Kw8+OX3zVsiBwZ9+K0m4cxBIt5H5QPyo40KU++IQXdQyrAr
         5R4JxTMSIZXCF1lDAsTFph51tkhFwwHCdCR4czEIqiH4HVAtnVQ5EUUaQIcv8hXUexw6
         nqZQ38a6Xd2RzSRQ7GK5n9ImdFKOcIWZbSUtBjKhsa44nA6Sr6j6KLjtmRqyTRnJ3u2B
         ho7VQBDynkDQwu5biBGl/WOVgod3pqdsAJ6/boOt5HVFMiC6IMZV2Bgw7EI53NGrHDWI
         RVuTqnvdVsOhlpErJ5K5q6hU+ZOwspFkkHWkZWYy2sEY3VeRvLf2q8LZB/7L6Gcfn6SR
         Omvg==
X-Google-Smtp-Source: APXvYqybhE51tYlXSXFeLLyMrHntdA396Ff4w4Uc+K8kWaM6Xff9spvB8kQdJb2DbhT9dJbTk0CE9g==
X-Received: by 2002:a17:902:e60a:: with SMTP id cm10mr127625731plb.316.1559095619659;
        Tue, 28 May 2019 19:06:59 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id h123sm17427729pfe.80.2019.05.28.19.06.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 19:06:58 -0700 (PDT)
Date: Tue, 28 May 2019 19:06:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrea Arcangeli <aarcange@redhat.com>
cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, 
    Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
    Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <20190524202931.GB11202@redhat.com>
Message-ID: <alpine.DEB.2.21.1905281840470.86034@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net> <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org> <20190524202931.GB11202@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 May 2019, Andrea Arcangeli wrote:

> > > We are going in circles, *yes* there is a problem for potential swap 
> > > storms today because of the poor interaction between memory compaction and 
> > > directed reclaim but this is a result of a poor API that does not allow 
> > > userspace to specify that its workload really will span multiple sockets 
> > > so faulting remotely is the best course of action.  The fix is not to 
> > > cause regressions for others who have implemented a userspace stack that 
> > > is based on the past 3+ years of long standing behavior or for specialized 
> > > workloads where it is known that it spans multiple sockets so we want some 
> > > kind of different behavior.  We need to provide a clear and stable API to 
> > > define these terms for the page allocator that is independent of any 
> > > global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
> > > workload dependent.
> > 
> > um, who is going to do this work?
> 
> That's a good question. It's going to be a not simple patch to
> backport to -stable: it'll be intrusive and it will affect
> mm/page_alloc.c significantly so it'll reject heavy. I wouldn't
> consider it -stable material at least in the short term, it will
> require some testing.
> 

Hi Andrea,

I'm not sure what patch you're referring to, unfortunately.  The above 
comment was referring to APIs that are made available to userspace to 
define when to fault locally vs remotely and what the preference should be 
for any form of compaction or reclaim to achieve that.  Today we have 
global enabling options, global defrag settings, enabling prctls, and 
madvise options.  The point it makes is that whether a specific workload 
fits into a single socket is workload dependant and thus we are left with 
prctls and madvise options.  The prctl either enables thp or it doesn't, 
it is not interesting here; the madvise is overloaded in four different 
ways (enabling, stalling at fault, collapsability, defrag) so it's not 
surprising that continuing to overload it for existing users will cause 
undesired results.  It makes an argument that we need a clear and stable 
means of defining the behavior, not changing the 4+ year behavior and 
giving those who regress no workaround.

> This is why applying a simple fix that avoids the swap storms (and the
> swap-less pathological THP regression for vfio device assignment GUP
> pinning) is preferable before adding an alloc_pages_multi_order (or
> equivalent) so that it'll be the allocator that will decide when
> exactly to fallback from 2M to 4k depending on the NUMA distance and
> memory availability during the zonelist walk. The basic idea is to
> call alloc_pages just once (not first for 2M and then for 4k) and
> alloc_pages will decide which page "order" to return.
> 

The commit description doesn't mention the swap storms that you're trying 
to fix, it's probably better to describe that again and why it is not 
beneficial to swap unless an entire pageblock can become free or memory 
compaction has indicated that additional memory freeing would allow 
migration to make an entire pageblock free.  I understand that's a 
invasive code change, but merging this patch changes the 4+ year behavior 
that started here:

commit 077fcf116c8c2bd7ee9487b645aa3b50368db7e1
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Wed Feb 11 15:27:12 2015 -0800

    mm/thp: allocate transparent hugepages on local node

And that commit's description describes quite well the regression that we 
encounter if we remove __GFP_THISNODE here.  That's because the access 
latency regression is much more substantial than what was reported for 
Naples in your changelog.

In the interest of making forward progress, can we agree that swapping 
from the local node *never* makes sense unless we can show that an entire 
pageblock can become free or that it enables memory compaction to migrate 
memory that can make an entire pageblock free?  Are you reporting swap 
storms for the local node when one of these is true?

> > Implementing a new API doesn't help existing userspace which is hurting
> > from the problem which this patch addresses.
> 
> Yes, we can't change all apps that may not fit in a single NUMA
> node. Currently it's unsafe to turn "transparent_hugepages/defrag =
> always" or the bad behavior can then materialize also outside of
> MADV_HUGEPAGE. Those apps that use MADV_HUGEPAGE on their long lived
> allocations (i.e. guest physical memory) like qemu are affected even
> with the default "defrag = madvise". Those apps are using
> MADV_HUGEPAGE for more than 3 years and they are widely used and open
> source of course.
> 

I continue to reiterate that the 4+ year long standing behavior of 
MADV_HUGEPAGE is overloaded; you are anticipating a specific behavior for 
workloads that do not fit in a single NUMA node whereas other users 
developed in the past four years are anticipating a different behavior.  
I'm trying to propose solutions that can not cause regressions for any 
user, such as the prctl() example that is inherited across fork, and can 
be used to define the behavior.  This could be a very trivial extension to 
prctl(PR_SET_THP_DISABLE) or it could be more elaborate as an addition.  
This would be set by any thread that forks qemu and can define that the 
workload prefers remote hugepages because it spans more than one node.  
Certainly we should agree that the majority of Linux workloads do not span 
more than one socket.  However, it *may* be possible to define this as a 
global thp setting since most machines that run large guests are only 
running large guests so the default machine-level policy can reflect that.


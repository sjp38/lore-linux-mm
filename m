Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B289C4332F
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 01:51:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE3312082C
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 01:51:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NRLREOs6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE3312082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C1EE6B0005; Sat,  7 Sep 2019 21:51:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 371EF6B0006; Sat,  7 Sep 2019 21:51:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 287D46B0007; Sat,  7 Sep 2019 21:51:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id 072586B0005
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:51:01 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 931176D89
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 01:51:01 +0000 (UTC)
X-FDA: 75910075122.27.pie98_431651e8b8945
X-HE-Tag: pie98_431651e8b8945
X-Filterd-Recvd-Size: 7139
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 01:51:00 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id d10so5666365pgo.5
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 18:51:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=KbxwZEXlmK2EHfzsJ8Z4ohJVr62bCYur63EuvHNOgHw=;
        b=NRLREOs6ZqJDZfHKwII31iUClnrqOfpMCT4wTorPp5hP830PZYXWCNqWaE6xo1XFcy
         C8wYyPFPma81I1fp90Ywbtgq0LpKsmkn53EjDm/W5zgQ6B9NFWVk9CcG9O/Q00yG2S4Z
         WIC9WSRr9I79GmSRwYbjxU3yr0/WIXU/RIUhDuhnBrC80ltNkpJCjTAKN4AuzvwN2y4U
         fKTIQR11ICnHQ5wSe7u4WKXRh4Q6OstlU0ExHGsL/Nq9SOT31ajGjSDP4gn2d5HKNf/+
         C5sLLV95qLMBEarM1rGAmyyZ4UxYjhaI/Tbb5YVfKKmk0qMEY6T9XAXlMUGoDkwCuEej
         cNhw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=KbxwZEXlmK2EHfzsJ8Z4ohJVr62bCYur63EuvHNOgHw=;
        b=ojEUnwXWl+9Z5Pr4s1+9NHC6t17/1gv19qa6nFUZivGLhDBUE19eTdFMC1Rq1eQSEW
         n9TD6tXs+yAD2LgcLujLrp34s+NIuiQGON7cjk8+szFpD0bDluSPenrHs6/w/4bdLXw3
         muhhXeUTbp2MIxNJoGQAbYHZPXLB+wjdELa/UxbnfUyB8wrqXnjv6Z9+XvL9sV5eRvOz
         TimMgLh0eazWpwxpfwZgwilrUKcfT/Vvw6nGI2sOAlTZHHVJ0o8tLgyTz1EvBjBxPsJX
         pm1n3MmtHXgJNLMQtnlIUsfId9sTe/QwbMUKTxnH9L/N5gjwxb8AyiMcDHe6WDSkLhl2
         t8dw==
X-Gm-Message-State: APjAAAV445rOXRpT41euKWBQgdwFfIgK0zE93oN7R1RDLfV27qXIjFE3
	6GciqwEsNWs1zobLb8kU06jTJQ==
X-Google-Smtp-Source: APXvYqyHIRUGqUEVgtpS5Qd1RlYBK10Uualc5xWB54lKewaqTzAfMyNDqIxsgeUahNEYZWNGD8Qp+A==
X-Received: by 2002:a17:90a:fc8:: with SMTP id 66mr18058273pjz.134.1567907459337;
        Sat, 07 Sep 2019 18:50:59 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id s186sm14149893pfb.126.2019.09.07.18.50.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Sep 2019 18:50:58 -0700 (PDT)
Date: Sat, 7 Sep 2019 18:50:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, 
    Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote
 hugepages
In-Reply-To: <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1909071829440.200558@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com> <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com> <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com> <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
 <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 7 Sep 2019, Linus Torvalds wrote:

> > Andrea acknowledges the swap storm that he reported would be fixed with
> > the last two patches in this series
> 
> The problem is that even you aren't arguing that those patches should
> go into 5.3.
> 

For three reasons: (a) we lack a test result from Andrea, (b) there's 
on-going discussion, particularly based on Vlastimil's feedback, and 
(c) the patches will be refreshed incorporating that feedback as well as 
Mike's suggestion to exempt __GFP_RETRY_MAYFAIL for hugetlb.

> So those fixes aren't going in, so "the swap storms would be fixed"
> argument isn't actually an argument at all as far as 5.3 is concerned.
> 

It indicates that progress has been made to address the actual bug without 
introducing long-lived access latency regressions for others, particularly 
those who use MADV_HUGEPAGE.  In the worst case, some systems running 
5.3-rc4 and 5.3-rc5 have the same amount of memory backed by hugepages but 
on 5.3-rc5 the vast majority of it is allocated remotely.  This incurs a 
signficant performance regression regardless of platform; the only thing 
needed to induce this is a fragmented local node that would otherwise be 
compacted in 5.3-rc4 rather than quickly allocate remote on 5.3-rc5.

> End result: we'd have the qemu-kvm instance performance problem in 5.3
> that apparently causes distros to apply those patches that you want to
> revert anyway.
> 
> So reverting would just make distros not use 5.3 in that form.
> 

I'm arguing to revert 5.3 back to the behavior that we have had for years 
and actually fix the bug that everybody else seems to be ignoring and then 
*backport* those fixes to 5.3 stable and every other stable tree that can 
use them.  Introducing a new mempolicy for NUMA locality into 5.3.0 that 
will subsequently changed in future 5.3 stable kernels and differs from 
all kernels from the past few years is not in anybody's best interest if 
the actual problem can be fixed.  It requires more feedback than a 
one-line "the swap storms would be fixed with this."  That collaboration 
takes time and isn't something that should be rushed into 5.3-rc5.

Yes, we can fix NUMA locality of hugepages when a workload like qemu is 
larger than a single socket; the vast majority of workloads in the 
datacenter are small than a socket and *cannot* incur the performance 
penalty if local memory is fragmented that 5.3-rc5 introduces.

In other words, 5.3-rc5 is only fixing a highly specialized usecase where 
remote allocation is acceptable because the workload is larger than a 
socket *and* remote memory is not low on memory or fragmented.  If you 
consider the opposite of that, workloads smaller than a socket or local 
compaction actually works, this has introduced a measurable regression for 
everybody else.

I'm not sure why we are ignoring a painfully obvious bug in the page 
allocator because of a poor feedback loop between itself and memory 
compaction and rather papering over it by falling back to remote memory 
when NUMA actually does matter.  If you release 5.3 without the first two 
patches in this series, I wouldn't expect any additional feedback or test 
results to fix this bug considering all we have gotten so far is "this 
would fix this swap storms" and not collaborating to fix the issue for 
everybody rather than only caring about their own workloads.  At least my 
patches acknowledge and try to fix the issue the other is encountering.


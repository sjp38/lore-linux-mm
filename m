Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91CE5C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:54:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C8E6206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:54:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WGDDlqn6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C8E6206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CABB86B0003; Mon, 20 May 2019 13:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5C5C6B0005; Mon, 20 May 2019 13:54:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B24286B0006; Mon, 20 May 2019 13:54:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9F06B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:54:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so10390899pfi.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=negm9dx6e3CAuNMPItfxB3GpMRhdOu53NazcRRhQGqQ=;
        b=mfoNB+VRKxS+vq2y/cX7YEW+6Itn1TY0RT8IQ03sbgmrUJh5PJMSNzoQGQf4L8745w
         h8RnMe5fHa1h52MIiHjKTVPU50BIn/GLsuZitFxlnP7PB6Y8OUmqwKIZVYXFm7SCeZ1r
         WZ4A9P3UtgytgRi2143LqQEX+kIncu1TiXkZR3YKaa7V7kGjTizOLTEkoqQdbF4zClu7
         LLO5mSK/3iz+Y2RWwEfLBlZgXm4LD6VHlOgeuVAHoPDvZSS4aYHKSbXJ0C6cs5t+Sjke
         h/thXMLN3vV9TVX6Xp9hDZQ+eCdZUox8USS8YulXM39c/mcaDh+kmUCqltOpfgO3gHxS
         FR+A==
X-Gm-Message-State: APjAAAXoijE1m+/4LBkEm1hmwwG1dSnt8LM9NbfeGyaRXmVy8bWnrS08
	FFz+axn7OYiCMTmYKyWT3K3R5lRnOoqYm66pl0n0cavAJJeO2XmtYQSKXjf/Bnbd9F8o9RZx/ww
	DvUr8L3eyvBJ+rnbBgtk4EXVoQ0uUy3EMESlW0Ux/G+fMmcshZstRKDEzRSPBgxk1Pg==
X-Received: by 2002:a17:902:728f:: with SMTP id d15mr3044972pll.167.1558374860033;
        Mon, 20 May 2019 10:54:20 -0700 (PDT)
X-Received: by 2002:a17:902:728f:: with SMTP id d15mr3044886pll.167.1558374858973;
        Mon, 20 May 2019 10:54:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558374858; cv=none;
        d=google.com; s=arc-20160816;
        b=ove7SXW3g9brPSNGnDdj0h4kEFibRKbhDqFUml2WtRn2zuGrh22jmPO44xw+9kAf5o
         tRvR9xpHpbRBM0k4a02VQJLaac/BV0vvnUfxFqHGYqo/kKf68yJup5o97BFlxZDKNAeC
         9FxhNovNxDyyu/ZPYm5dM6cuk0ONLRFJInpu1bpy8JmwD83Nc16w4fw21ZMMt27y/KYn
         CDDbZ/HuoUnKb0XMaCMo3aWnC0fDNj+mh2fNkqDbwHv/cRItxjqQodMBzgQ3xMoZcwTp
         U1N5+Fq4Z/JPX1kPAg5jWsE5xzjmB1xrjGodlZNQ7vGdoKs0/1W6acG4jo8Qklizd+qq
         iCeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=negm9dx6e3CAuNMPItfxB3GpMRhdOu53NazcRRhQGqQ=;
        b=Ldo1hhuSgud9TGvsslPgHgOeRLJRbpooBKOAagFy1CIlYCmF9FNPFU+u8jNeue76M8
         gtAhDTnFeK+88hgnujKX97cUdEZtmbSxYlLTIsQHHDT2lnjkKTVXdIKLXNygOjgWvmYG
         if3Mzo7AdYdKVYRuVqh9YZ8Tn93q6xLrqNwhdjZnUpJ75EMlV4QXxyrxJDZd7jZUoMpu
         fbO8wbUR9YzkQHM85cT8IKl02DsY9BWYUULjYpOw85YE9qPzWBwJiEo9TZqiuh9bpYni
         G3VEOy8UENNoYWwHghR8N/8B+VVPRxAITwbkt4TE+Nf7pnDFRd4K1CVDyCqGriu6X0ZT
         DZ5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WGDDlqn6;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j38sor20108295plb.12.2019.05.20.10.54.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:54:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WGDDlqn6;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=negm9dx6e3CAuNMPItfxB3GpMRhdOu53NazcRRhQGqQ=;
        b=WGDDlqn6IPQQZ5DbWzBIGH28tCmwv4KQnQaTnmp+kjp9u67iSNZrdDCFDYOekKIJ6R
         Bg1yycCAmtSOt9znejTQNix1abGq7f6Ef2/WBPGapkB1a0mSpJAz6hATvIVnHTjKTTy3
         ow8yj7HWVkwzXi20KJqMXvnocADBZekv0qfW5cMxJMFtxHxbkuGVOp6UgtLDTs65u4wQ
         zGNyb2/qvmCNmFVlT9PixIcIyKYw5EB4E7GULEdrP6tGje1lopblt74j5IO9+QNSMGrz
         jkG1Ov+lJpYl+ugO3L84xsTf6LovjGU2Wgw9sVapMkwTSP2hd4pR1nOAAFRs8HwUZf5o
         Q3CQ==
X-Google-Smtp-Source: APXvYqzFXYf6cM9NA8Wa4huJfaI7RgWDRkBaPiGYDuVx55OVH2+QRgtCnrFWXUGO2OYjYt2NoIrh/w==
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr29097059plb.240.1558374858142;
        Mon, 20 May 2019 10:54:18 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id j8sm3610519pfi.148.2019.05.20.10.54.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 10:54:16 -0700 (PDT)
Date: Mon, 20 May 2019 10:54:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Mel Gorman <mgorman@suse.de>
cc: Andrea Arcangeli <aarcange@redhat.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
    Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <20190520153621.GL18914@techsingularity.net>
Message-ID: <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 May 2019, Mel Gorman wrote:

> > There was exhausting discussion subsequent to this that caused Linus to 
> > have to revert the offending commit late in an rc series that is not 
> > described here. 
> 
> Yes, at the crux of that matter was which regression introduced was more
> important -- the one causing swap storms which Andrea is trying to address
> or a latency issue due to assumptions of locality when MADV_HUGEPAGE
> is used.
> 
> More people are affected by swap storms and distributions are carrying
> out-of-tree patches to address it. Furthermore, multiple people unrelated
> to each other can trivially reproduce the problem with test cases and
> experience the problem with real workloads. Only you has a realistic
> workload sensitive to the latency issue and we've asked repeatedly for
> a test case (most recently Michal Hocko on May 4th) which is still not
> available.
> 

Hi Mel,

Any workload that does MADV_HUGEPAGE will be impacted if remote hugepage 
access latency is greater than local native page access latency and is 
using the long-standing behavior of the past three years.  The test case 
would be rather straight forward: induce node local fragmentation (easiest 
to do by injecting a kernel module), do MADV_HUGEPAGE over a large range, 
fault, and measure random access latency.  This is readily observable and 
can be done synthetically to measure the random access latency of local 
native pages vs remote hugepages.  Andrea provided this testcase in the 
original thread.  My results from right now:

# numactl -m 0 -C 0 ./numa-thp-bench
random writes MADV_HUGEPAGE 17492771 usec
random writes MADV_NOHUGEPAGE 21344846 usec
random writes MADV_NOHUGEPAGE 21399545 usec
random writes MADV_HUGEPAGE 17481949 usec
# numactl -m 0 -C 64 ./numa-thp-bench
random writes MADV_HUGEPAGE 26858061 usec
random writes MADV_NOHUGEPAGE 31067825 usec
random writes MADV_NOHUGEPAGE 31334770 usec
random writes MADV_HUGEPAGE 26785942 usec

That's 25.8% greater random access latency when going across socket vs 
accessing local native pages.

> > This isn't an argument in support of this patch, there is a difference 
> > between (1) pages of the native page size being faulted first locally
> > falling back remotely and (2) hugepages being faulted first locally and 
> > falling back to native pages locally because it has better access latency 
> > on most platforms for workloads that do not span multiple nodes.  Note 
> > that the page allocator is unaware whether the workload spans multiple 
> > nodes so it cannot make this distinction today, and that's what I'd prefer 
> > to focus on rather than changing an overall policy for everybody.
> > 
> 
> Overall, I think it would be ok to have behaviour whereby local THP is
> allocated if cheaply, followed by base pages local followed by the remote
> options. However, __GFP_THISNODE removes the possibility of allowing
> remote fallback and instead causing a swap storm and swap storms are
> trivial to generate on NUMA machine running a mainline kernel today.
> 

Yes, this is hopefully what we can focus on and I hope we can make forward 
progress with (1) extending mempolicies to allow specifying hugepage 
specific policies, (2) the prctl(), (3) improving the feedback loop 
between compaction and direct reclaim, and/or (4) resolving the overloaded 
the conflicting meanings of 
/sys/kernel/mm/transparent_hugepage/{enabled,defrag} and 
MADV_HUGEPAGE/MADV_NOHUGEPAGE.

The issue here is the overloaded nature of what MADV_HUGEPAGE means and 
what the system-wide thp settings mean.  It cannot possibly provide sane 
behavior of all possible workloads given only two settings.  MADV_HUGEPAGE 
itself has *four* meanings: (1) determine hugepage eligiblity when not 
default, (2) try to do sychronous compaction/reclaim at fault, (3) 
determine eligiblity of khugepaged, (4) control defrag settings based on 
system-wide setting.  The patch here is adding a fifth: (5) prefer remote 
allocation when local memory is fragmented.  None of this is sustainable.

Note that this patch is also preferring remote hugepage allocation *over* 
local hugepages before trying memory compaction locally depending on the 
setting of vm.zone_reclaim_mode so it is infringing on the long-standing 
behavior of (2) as well.

In situations such as these, it is not surprising that there are issues 
reported with any combination of flags or settings and patches get 
proposed to are very workload dependent.  My suggestion has been to move 
in a direction where this can be resolved such that userspace has a clean 
and stable API and we can allow remote hugepage allocation for workloads 
that specifically opt-in, but not incur 25.8% greater access latency for 
using the behavior of the past 3+ years.

Another point that has consistently been raised on LKML is the inability 
to disable MADV_HUGEPAGE once set: i.e. if you set it for faulting your 
workload, you are required to do MADV_NOHUGEPAGE to clear it and then are 
explicitly asking that this memory is not backed by hugepages.

> > It may not have been meant to provide this, but when IBM changed this 
> > three years ago because of performance regressions and others have started 
> > to use MADV_HUGEPAGE with that policy in mind, it is the reality of what 
> > the madvise advice has provided.  What was meant to be semantics of 
> > MADV_HUGEPAGE three years ago is irrelevant today if it introduces 
> > performance regressions for users who have used the advice mode during 
> > that past three years.
> > 
> 
> Incurring swap storms when there is plenty of free memory available is
> terrible. If the working set size is larger than a node, the swap storm
> may even persist indefinitely.
> 

Let's fix it.

> > Yes, this is clearly understood and was never objected to when this first 
> > came up in the thread where __GFP_THISNODE was removed or when Linus 
> > reverted the patch.
> > 
> > The issue being discussed here is a result of MADV_HUGEPAGE being 
> > overloaded: it cannot mean to control (1) how much compaction/reclaim is 
> > done for page allocation, (2) the NUMA locality of those hugepages, and 
> > (3) the eligibility of the memory to be collapsed into hugepages by 
> > khugepaged all at the same time.
> > 
> > I suggested then that we actually define (2) concretely specifically for 
> > the usecase that you mention.  Changing the behavior of MADV_HUGEPAGE for 
> > the past three years, however, and introducing performance regressions for 
> > those users is not an option regardless of the intent that it had when 
> > developed.
> > 
> 
> The current behaviour is potential swap storms that are difficult to
> avoid because the behaviour is hard-wired into the kernel internals.
> Only disabling THP, either on a task or global basis, avoids it when
> encountered.
> 

We are going in circles, *yes* there is a problem for potential swap 
storms today because of the poor interaction between memory compaction and 
directed reclaim but this is a result of a poor API that does not allow 
userspace to specify that its workload really will span multiple sockets 
so faulting remotely is the best course of action.  The fix is not to 
cause regressions for others who have implemented a userspace stack that 
is based on the past 3+ years of long standing behavior or for specialized 
workloads where it is known that it spans multiple sockets so we want some 
kind of different behavior.  We need to provide a clear and stable API to 
define these terms for the page allocator that is independent of any 
global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
workload dependent.

Is it deserving of an MADV_REMOTE_HUGEPAGE, a prctl(), hugepage extended 
mempolicies, or something else?  I'm positive that the problem is 
understood and we could reach some form of consensus before an 
implementation is invested into if we actually discuss ways to fix the 
underlying issue.

Thanks.


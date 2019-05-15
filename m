Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06723C072AD
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:26:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FC502084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:26:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eeTNkxvB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FC502084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0C86B0008; Wed, 15 May 2019 16:26:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345A66B000A; Wed, 15 May 2019 16:26:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BF886B000C; Wed, 15 May 2019 16:26:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D36956B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 16:26:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a90so548374plc.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 13:26:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=7GCJu3e00+ByAZup6FNmBpyKX/4mnNVOoHvXU7BIXUg=;
        b=kfTtub5jbZcLc7pplfYjZkA62ob+Yo3+hZfj97xlv+X4cnnb+j75+XtzK3OfEQs54Y
         qw2jZ4pUf6HtU28mC4+aRFenZU+YB9vdqf+ZL5sRw3Rp48zFD9Rh/dxpweQeWlDtt4v2
         qEkA/RJbooMRJpnphGVPGmUDl1gaTPaOzD57oJbltDxqpdeKH/1dqquQtCIvFfYH9QUo
         r9CT7Y6ifi2SqkRCgKylQP6iOioK9aAoyDFnUNAgmwghcpTBVrzrkYrVb6NG+HMjWP1w
         Cfx+TUpxNLxh6PKo/yv79i9/s58D/QrzwyRQy7wpphSNKWjrQ2PWzUAwOiQvSefUekan
         WbwQ==
X-Gm-Message-State: APjAAAVCfn/OTouywK3QiDeV1LEOGd5N9f2Rkrb2yuXOFNfs1X5cjnJ0
	8t+V7hgNJxP7DOe3/bE3+BF/iMMCuGaKkeIx4rxVBBIBXhaZ02BS9zyiQnsJk9I1EdW07on3cL5
	M7JP7Kc3Y1N6NqYVYA3cbA20RwJF03AThg2Uk8v5IMNSpejCSfYsrpvRSoIIA4GvKqw==
X-Received: by 2002:a63:730f:: with SMTP id o15mr45796359pgc.315.1557951991337;
        Wed, 15 May 2019 13:26:31 -0700 (PDT)
X-Received: by 2002:a63:730f:: with SMTP id o15mr45796276pgc.315.1557951990353;
        Wed, 15 May 2019 13:26:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557951990; cv=none;
        d=google.com; s=arc-20160816;
        b=hcF7hRCSFA8NHNCaEaYJ/1g4TsO/lt4tIlxqijoWhpmgTgyifPucVxj80brJd1QswB
         Oxt3GN716Lgt4LcBFLds5Z4x7Ousl1W49L6Wq/LCvglowba/b5XIW0mG8InSon4vcl98
         Wbcm7kjxivTKn1Civ1hKeGXy0WKlnmRlfVv1qfjJd6dZ7wbSmumJaz8TA6OYeQHFiQ2S
         L/HqhIz5ayNZlbSmTuQ/GDUg6Ims9yvZqnxzGEOm7FGH0mYdvBzprAtgzhjQbOczESDk
         DvLFAtSAKlDh2PKvahFlDnfiYD9RtZUIJIXBDSAsBwU8qxccEqyZFWOSAKmlmYdYYMCN
         g74Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=7GCJu3e00+ByAZup6FNmBpyKX/4mnNVOoHvXU7BIXUg=;
        b=vMA3cp5G4bJXoF3PLghqHnnlHnoqqgpbEG0/x5ye7lm0erMmiXMAXC1QDNLT/qA8h6
         dXLUTMet5Hq+Rv3kzRqNnNuoNAg02BBLl5EFGdOLboOA3gl1Jfckd2wC7HnpzHRjLC8B
         nqoYm6B7QWt7whNah4AcglBR08J5+SUUa40jA8ESltL67eJa2GmzEZTDMuBnKK9fz1SN
         z+Sb/nFvoZQxo2ah5TOEFv5/7h4lmui0rTDg9FbKW1fKLJmr181eJ39lz0/kpjrweTsU
         CgAGGWAKZLIMtGEhn+0cDbvTBNMhsrDRLNz/VbGJK5OuLXs2B/49851bAh3Aujx99obf
         OBhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eeTNkxvB;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12sor3507180plk.37.2019.05.15.13.26.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 13:26:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eeTNkxvB;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=7GCJu3e00+ByAZup6FNmBpyKX/4mnNVOoHvXU7BIXUg=;
        b=eeTNkxvBZp2POBlL5aTW8ruleiH5J3PtkSS19oeA7wa72YpIa9wkSsli1Ubb5CZSu8
         qUWEQYPGQVvudxuKXUkDToTq8kO+JP84ekQdXcUPTaQ1WGrd1FtOuYwV7o7pWtuWIiaE
         HjhyvDv/tpURtO6SvXnKCK3gMs8qafWUX6FMJq4P3jrj+tZN7YD356tzgwIWzROKLrze
         MmQzcSVvP78tOlcZwAigtYE+MpbrKGCFb/mqXMAg6nr1vsI+GTo8f1SWDLSRmpWkzr7z
         LQ6uifUMFK2mp9W/YiqkSYpdmNFu+SKzVGrdejyyvYXPlRn0Nq+SNBv2h2JsGfAko1iQ
         PtfA==
X-Google-Smtp-Source: APXvYqyGL2ajcTRT22h5fz2XDaak81L69d5WO3KmM9JrxeK/8rBx6RajhkbzaZ/IS4yqZ+iwzm3A7w==
X-Received: by 2002:a17:902:7584:: with SMTP id j4mr2594939pll.185.1557951988931;
        Wed, 15 May 2019 13:26:28 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id a18sm6192033pfr.22.2019.05.15.13.26.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 13:26:27 -0700 (PDT)
Date: Wed, 15 May 2019 13:26:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrea Arcangeli <aarcange@redhat.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, 
    Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <20190503223146.2312-3-aarcange@redhat.com>
Message-ID: <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 May 2019, Andrea Arcangeli wrote:

> This reverts commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2.
> 
> commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2 was rightfully applied
> to avoid the risk of a severe regression that was reported by the
> kernel test robot at the end of the merge window. Now we understood
> the regression was a false positive and was caused by a significant
> increase in fairness during a swap trashing benchmark. So it's safe to
> re-apply the fix and continue improving the code from there. The
> benchmark that reported the regression is very useful, but it provides
> a meaningful result only when there is no significant alteration in
> fairness during the workload. The removal of __GFP_THISNODE increased
> fairness.
> 

Hi Andrea,

There was exhausting discussion subsequent to this that caused Linus to 
have to revert the offending commit late in an rc series that is not 
described here.  This was after the offending commit, which this commit 
now reintroduces, was described as causing user facing access latency 
regressions and nacked.  The same objection is obviously going to be made 
here and I'd really prefer if this could be worked out without yet another 
merge into -mm, push to Linus, and revert by Linus.  There are solutions 
to this issue that does not cause anybody to have performance regressions 
rather than reintroducing them for a class of users that use the 
overloaded MADV_HUGEPAGE for the purposes it has provided them over the 
past three years.

> __GFP_THISNODE cannot be used in the generic page faults path for new
> memory allocations under the MPOL_DEFAULT mempolicy, or the allocation
> behavior significantly deviates from what the MPOL_DEFAULT semantics
> are supposed to be for THP and 4k allocations alike.
> 

This isn't an argument in support of this patch, there is a difference 
between (1) pages of the native page size being faulted first locally
falling back remotely and (2) hugepages being faulted first locally and 
falling back to native pages locally because it has better access latency 
on most platforms for workloads that do not span multiple nodes.  Note 
that the page allocator is unaware whether the workload spans multiple 
nodes so it cannot make this distinction today, and that's what I'd prefer 
to focus on rather than changing an overall policy for everybody.

> Setting THP defrag to "always" or using MADV_HUGEPAGE (with THP defrag
> set to "madvise") has never meant to provide an implicit MPOL_BIND on
> the "current" node the task is running on, causing swap storms and
> providing a much more aggressive behavior than even zone_reclaim_node
> = 3.
> 

It may not have been meant to provide this, but when IBM changed this 
three years ago because of performance regressions and others have started 
to use MADV_HUGEPAGE with that policy in mind, it is the reality of what 
the madvise advice has provided.  What was meant to be semantics of 
MADV_HUGEPAGE three years ago is irrelevant today if it introduces 
performance regressions for users who have used the advice mode during 
that past three years.

> Any workload who could have benefited from __GFP_THISNODE has now to
> enable zone_reclaim_mode=1||2||3. __GFP_THISNODE implicitly provided
> the zone_reclaim_mode behavior, but it only did so if THP was enabled:
> if THP was disabled, there would have been no chance to get any 4k
> page from the current node if the current node was full of pagecache,
> which further shows how this __GFP_THISNODE was misplaced in
> MADV_HUGEPAGE. MADV_HUGEPAGE has never been intended to provide any
> zone_reclaim_mode semantics, in fact the two are orthogonal,
> zone_reclaim_mode = 1|2|3 must work exactly the same with
> MADV_HUGEPAGE set or not.
> 
> The performance characteristic of memory depends on the hardware
> details. The numbers below are obtained on Naples/EPYC architecture
> and the N/A projection extends them to show what we should aim for in
> the future as a good THP NUMA locality default. The benchmark used
> exercises random memory seeks (note: the cost of the page faults is
> not part of the measurement).
> 
> D0 THP | D0 4k | D1 THP | D1 4k | D2 THP | D2 4k | D3 THP | D3 4k | ...
> 0%     | +43%  | +45%   | +106% | +131%  | +224% | N/A    | N/A
> 

The performance measurements that we have on Naples shows a more 
significant change between D0 4k and D1 THP: it certainly is not 2% worse 
access latency to a remote hugepage compared to local native pages.

> D0 means distance zero (i.e. local memory), D1 means distance
> one (i.e. intra socket memory), D2 means distance two (i.e. inter
> socket memory), etc...
> 
> For the guest physical memory allocated by qemu and for guest mode kernel
> the performance characteristic of RAM is more complex and an ideal
> default could be:
> 
> D0 THP | D1 THP | D0 4k | D2 THP | D1 4k | D3 THP | D2 4k | D3 4k | ...
> 0%     | +58%   | +101% | N/A    | +222% | N/A    | N/A   | N/A
> 
> NOTE: the N/A are projections and haven't been measured yet, the
> measurement in this case is done on a 1950x with only two NUMA nodes.
> The THP case here means THP was used both in the host and in the
> guest.
> 

Yes, this is clearly understood and was never objected to when this first 
came up in the thread where __GFP_THISNODE was removed or when Linus 
reverted the patch.

The issue being discussed here is a result of MADV_HUGEPAGE being 
overloaded: it cannot mean to control (1) how much compaction/reclaim is 
done for page allocation, (2) the NUMA locality of those hugepages, and 
(3) the eligibility of the memory to be collapsed into hugepages by 
khugepaged all at the same time.

I suggested then that we actually define (2) concretely specifically for 
the usecase that you mention.  Changing the behavior of MADV_HUGEPAGE for 
the past three years, however, and introducing performance regressions for 
those users is not an option regardless of the intent that it had when 
developed.

I suggested two options: (1) __MPOL_F_HUGE flag to set a mempolicy for 
specific memory ranges so that you can define thp specific mempolicies 
(Vlastimil considered this to be a lot of work, which I agreed) or (2) a 
prctl() mode to specify that a workload will span multiple sockets and 
benefits from remote hugepage allocation over local native pages (or 
because it is faulting memory remotely that it will access locally at some 
point in the future depending on cpu binding).  Any prctl() mode can be 
inherited across fork so it can be used for the qemu case that you suggest 
and is a very simple change to make compared with (1).

Please consider methods to accomplish this goal that will not cause 
existing users of MADV_HUGEPAGE to incur 13.9% access latency regressions 
and have no way to workaround without MPOL_BIND that will introduce 
undeserved and unnecessary oom kills because we can't specify native page 
vs hugepage mempolicies independently.

I'm confident that everybody on this cc list is well aware of both sides 
of this discussion and I hope that we can work together to address it to 
achieve the goals of both.

Thanks.


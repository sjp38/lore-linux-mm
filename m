Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C1AC3A5AB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:54:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 718B522CF7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 19:54:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="O86lsLAw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 718B522CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D54E16B0003; Wed,  4 Sep 2019 15:54:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D05186B0006; Wed,  4 Sep 2019 15:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1ABC6B000A; Wed,  4 Sep 2019 15:54:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCCB6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:54:19 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 45935A2B4
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:54:19 +0000 (UTC)
X-FDA: 75898289838.04.town55_7cf892fd8601a
X-HE-Tag: town55_7cf892fd8601a
X-Filterd-Recvd-Size: 5682
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:54:18 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id k1so13845pls.11
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 12:54:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=zVEggXc4NanJ8GS8Ki3BGLJbkMKiAmWM9IclbMTNoGs=;
        b=O86lsLAw4Av2uvQ+fhP7kYtfih5r6K05xH+HGpxKSb7ZFLw+X4Q3l0cAMoWMXsX5+1
         yRtHeSn+fmF1rvDKrLfzLrucSV9UosmCkfmV2nbV80DaLIZPSK8TDel1Q94h8Qc0+PDi
         g0e5ecZ3RWr83+gZTuBtYc8KP8rrO6WYfHA0CpOkAW4Uw4+Pm+nnbEaZF2xtMvc3JC7a
         mdLCO7NMtd2sS+S+zkBBeg3bhuOm1I0zSVJK+w92TCPNPnFyp8ZQ0quZOPoKkxZ5KE/o
         LJiK55VbvSakXB2dv6LHRaNZ8zzPVrN24mzMW4z0X5WQpOYPAKQCj7bduBN0jRep2crq
         aaNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:user-agent
         :mime-version;
        bh=zVEggXc4NanJ8GS8Ki3BGLJbkMKiAmWM9IclbMTNoGs=;
        b=QObMPn10E9C4FKIgM/Rivve85B9Uh6XEq8IqQW+N+u0GljSLdD8MVKF7zWHuCI57+H
         saobM/f8qVT+3Kih7sLoB/4f0jzbRahEv2D9F1yQApn+Ao0iYR+lICIU7O8cV5h6slsy
         OVXX2gUzdsUr1OiImyDNzp/eoxAtcwAYukLW/M/h7zk0qYDNYafBzfC6MFpl1DjjE+ow
         6ITkml3185AOKMybshhS52QoxTMYl2UAQ6SwZh4is3oGy+sRzeGxu++Lwb6p8H+ip6Eo
         T/jojn2zoHibPdTde9FqxVLrW6tc0wQPltDEjTKKurOTuYE22R3V1zyIk23bqytIE7HW
         yFXg==
X-Gm-Message-State: APjAAAXMzoojfCSAigKk4Le+6FeEShaJEpaOwPUPTv9V71KEnH234GL3
	LAOdm0uuSvGnM4M2CHUdQTz9dA==
X-Google-Smtp-Source: APXvYqwR/4/43dbf9ZNog736j7K01wvmb9AMqM1m0dVw7+TYaOgrQwy2t1siHO4MQsCO51RQKPTjxg==
X-Received: by 2002:a17:902:6b06:: with SMTP id o6mr42019502plk.33.1567626857331;
        Wed, 04 Sep 2019 12:54:17 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id y15sm30056819pfp.111.2019.09.04.12.54.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 12:54:16 -0700 (PDT)
Date: Wed, 4 Sep 2019 12:54:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>
cc: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, 
    Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
Message-ID: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Two commits:

commit a8282608c88e08b1782141026eab61204c1e533f
Author: Andrea Arcangeli <aarcange@redhat.com>
Date:   Tue Aug 13 15:37:53 2019 -0700

    Revert "mm, thp: restore node-local hugepage allocations"

commit 92717d429b38e4f9f934eed7e605cc42858f1839
Author: Andrea Arcangeli <aarcange@redhat.com>
Date:   Tue Aug 13 15:37:50 2019 -0700

    Revert "Revert "mm, thp: consolidate THP gfp handling into alloc_hugepage_direct_gfpmask""

made their way into 5.3-rc5

We (mostly Linus, Andrea, and myself) have been discussing offlist how to
implement a sane default allocation strategy for hugepages on NUMA
platforms.

With these reverts in place, the page allocator will happily allocate a
remote hugepage immediately rather than try to make a local hugepage
available.  This incurs a substantial performance degradation when
memory compaction would have otherwise made a local hugepage available.

This series reverts those reverts and attempts to propose a more sane
default allocation strategy specifically for hugepages.  Andrea
acknowledges this is likely to fix the swap storms that he originally
reported that resulted in the patches that removed __GFP_THISNODE from
hugepage allocations.

The immediate goal is to return 5.3 to the behavior the kernel has
implemented over the past several years so that remote hugepages are
not immediately allocated when local hugepages could have been made
available because the increased access latency is untenable.

The next goal is to introduce a sane default allocation strategy for
hugepages allocations in general regardless of the configuration of the
system so that we prevent thrashing of local memory when compaction is
unlikely to succeed and can prefer remote hugepages over remote native
pages when the local node is low on memory.

Merging these reverts late in the rc cycle to change behavior that has
existed for years and is known (and acknowledged) to create performance
degradations when local hugepages could have been made available serves
no purpose other than to make the development of a sane default policy
much more difficult under time pressure and to accelerate decisions that
will affect how userspace is written (and how it has regressed) that
otherwise require carefully crafted and detailed implementations.

Thus, this patch series returns 5.3 to the long-standing allocation
strategy that Linux has had for years and proposes to follow-up changes
that can be discussed that Andrea acknowledges will avoid the swap storms
that initially triggered this discussion in the first place.


Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E217BC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:24:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80BA224204
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:24:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wVDIB2aj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80BA224204
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26656B0270; Wed, 29 May 2019 17:24:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6666B0271; Wed, 29 May 2019 17:24:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC7966B0272; Wed, 29 May 2019 17:24:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85F126B0270
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:24:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v125so807475pgv.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:24:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=/VjnBzka0ntx7tOJYYS02mgCPrG/ZdRlbuD+pRSLDes=;
        b=JNOfoKgiDpu+NcXognZJmtYG6QKPQl/wCXpdFIlxTuzt6n88CO0alCBdWtoLSb7C2W
         gT2/Dyx8fHrju4UHw+z/Bq1/VbOeX6HatOgqgeL03rKiVC5+D0DJNHxcWXe+yHQBHBTN
         M7Pqcy2MVsxwj7zJnH3e3CmLuiWf3pNxRe6D45XWmiBqzc47RdKuDaFErPskXevvhqSh
         3JAA4x5hX1UCESK0keKJ0BF8zeACKKgkBtGXQsYtmM2A+Dk5E+oA6VNn0W6tLRO8gyFS
         QehTarOj3DZXru2np3lfuxdYSDvdyBSqGXrWFKc2VXtQs20WvFe/3c5hGigK3g6a7H9A
         Z6Fg==
X-Gm-Message-State: APjAAAUkg/UJAYbZ52ngoNpD0jg3cfj3DcKoroP7u3rJ5JtYnremcIDa
	or4rH2WpeogLAg25gpamSatO4d9erG1gwNBsTpIXskNgQAZ8H2pwriYetdbwJ+CzZoVhL6O8PQP
	PT9ntUAkS6Z7NPZ3zmJZewn9P2uDcHaiI1t5XUXiVhwLej29mSMBLIj77lnSWeHa4hg==
X-Received: by 2002:a17:90a:480a:: with SMTP id a10mr14937910pjh.57.1559165077102;
        Wed, 29 May 2019 14:24:37 -0700 (PDT)
X-Received: by 2002:a17:90a:480a:: with SMTP id a10mr14937866pjh.57.1559165076372;
        Wed, 29 May 2019 14:24:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165076; cv=none;
        d=google.com; s=arc-20160816;
        b=H10u2/1R2hJoO8Z3LHTHhXeNvKeVtcWGO0OKYbpA1BpK22RUItRY1pfWM6JDmSCt4O
         owFfWiegv/hu/htp66bAJEMrajLHa8r+c7Biu3P1bCz/8DDYDrBdtvanqCuMxShaP5pc
         kLrGG03+cA3NwBWwR25zk9a0/ns2foBqhEHpLeGPEMiPIXroz6RzYbDR4BrDsWy2iiXY
         KXcrmzyYkUGI5DN81q8gwvqoepFAcnkuIO8+bckoVdrwWC3d/lI33imA7FrC0DVxBBxX
         fo2j2LFew8gr2njFtE9wKHPPdfGwvZ7PhUF8mb8kypp0walF7O7VbjI/O7x7tV07z5hv
         uhoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=/VjnBzka0ntx7tOJYYS02mgCPrG/ZdRlbuD+pRSLDes=;
        b=BE8IU6e33+INpZ5vyHolKv6UL/gIpyVqUsQWQZSzFDlA+GxsYZzYHqbbnzCGoVj/B6
         jdEPKT7+lIRNl/AUAN73qSWyKEAZ6VywTUy40aze6c9ARWTae78DLIIh9ASBI3Lp29i9
         2iila/EGsaTTmwh11bZ96yVJ4mE2T1ljicz15eZCCX662W0+DXKaD12mxGfdbCThI7+l
         lYB8AqIOouk0wab8NPSchcD16S/emY9SMu4n+aqPxsI2CJCyNrIxSOslhjhLQZ24EWq8
         7spPeiasSe8Dm1ZYOmFjx6+ZEMoXIQH88yCJ9Alxobyhy/qXjc6w0X2vDU3F+y5oPC4u
         6hHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wVDIB2aj;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d33sor724997pla.46.2019.05.29.14.24.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 14:24:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wVDIB2aj;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=/VjnBzka0ntx7tOJYYS02mgCPrG/ZdRlbuD+pRSLDes=;
        b=wVDIB2ajNcHg7hsPFzPNMH3O9KEy1WDcsjQKtoka4U2ZBN1vZ7D+qKxIibQrm38LYC
         Nrdwur3uPpDLwjQ4TnC1AV859Jt1/RP1YMONTS+JgDUk3vIVq+D1t9daEwQF1yAa/OBM
         I107FaouZn5cM26PVMcp6ROnM63unZjjgW6iZCihgLfgxHj3wQMN159WDsbad4Zd4AtL
         yYJ+3l7wbh+b1pmR5gpoJ1aJMSFW2TAby0fYs8G+P6By6Qz34969Jz6sRtm2i3F0KHLa
         m/ZpLlBuMgH5A8ottpc7PubUz1+V7uIL40yY7L+G5EpeFquPpFxl9a0B3pN8+4gIYiV3
         ph0w==
X-Google-Smtp-Source: APXvYqw5AnaaWWqmrWqXULzKKuTxZx2r0lmDn7r1dm5gO3QKz0czvs4AxpYS2G/AGO46AAVsVkcBwA==
X-Received: by 2002:a17:902:27a8:: with SMTP id d37mr25680plb.150.1559165075643;
        Wed, 29 May 2019 14:24:35 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id m7sm613626pff.44.2019.05.29.14.24.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 14:24:34 -0700 (PDT)
Date: Wed, 29 May 2019 14:24:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrew Morton <akpm@linux-foundation.org>
cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
    Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net> <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 May 2019, Andrew Morton wrote:

> > We are going in circles, *yes* there is a problem for potential swap 
> > storms today because of the poor interaction between memory compaction and 
> > directed reclaim but this is a result of a poor API that does not allow 
> > userspace to specify that its workload really will span multiple sockets 
> > so faulting remotely is the best course of action.  The fix is not to 
> > cause regressions for others who have implemented a userspace stack that 
> > is based on the past 3+ years of long standing behavior or for specialized 
> > workloads where it is known that it spans multiple sockets so we want some 
> > kind of different behavior.  We need to provide a clear and stable API to 
> > define these terms for the page allocator that is independent of any 
> > global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
> > workload dependent.
> 
> um, who is going to do this work?
> 
> Implementing a new API doesn't help existing userspace which is hurting
> from the problem which this patch addresses.
> 

The problem which this patch addresses has apparently gone unreported for 
4+ years since

commit 077fcf116c8c2bd7ee9487b645aa3b50368db7e1
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Wed Feb 11 15:27:12 2015 -0800

    mm/thp: allocate transparent hugepages on local node

My goal is to reach a solution that does not cause anybody to incur 
performance penalties as a result of it.  It's surprising that such a 
severe swap storm issue that went unnoticed for four years is something 
that can't reach an amicable solution that doesn't cause other users to 
regress.

> It does appear to me that this patch does more good than harm for the
> totality of kernel users, so I'm inclined to push it through and to try
> to talk Linus out of reverting it again.  
> 

(1) The totality of kernel users are not running workloads that span 
multiple sockets, it's the minority, (2) it's changing 4+ year behavior 
based on NUMA locality of hugepage allocations and provides no workarounds 
for users who incur regressions as a result, and (3) does not solve the 
underlying issue if remote memory is also fragmented or low on memory: it 
actually makes the problem worse.

The easiest solution would be to define the MADV_HUGEPAGE behavior 
explicitly in sysfs: local or remote.  Defaut to local as the behavior 
from the past four years and allow users to specify remote if their 
workloads will span multiple sockets.  This is somewhat coarse but no more 
than the thp defrag setting in sysfs today that defines defrag behavior 
for everybody on the system.


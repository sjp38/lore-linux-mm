Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E02B5C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:58:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E5EC208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:58:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hMKvk3yB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E5EC208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31C916B0007; Tue, 23 Apr 2019 14:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CAEF6B0008; Tue, 23 Apr 2019 14:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E1CA6B000A; Tue, 23 Apr 2019 14:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0A396B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:58:09 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n11so696678wmh.2
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:58:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=hlctpjjq5WkzFrwqOfa4m7NMkfdbQu2AODSgExXY384=;
        b=fWuAMxK6xH6PuAGq0AbAiHSAGMmg9CzXp6sNZiOoZcjQ+Uqw+vo0B6b+Xlcw/Sk1Qt
         bUExPpnB694NkZfBNaKZ2TW54DnPymaJQtTLT3DmcPrnaJomde2qquycqWRqNotxBCXl
         GTffH/sFj/H6nnGtXnaGXI2ihcdhLB8zt+o1mhGKpt1VvXWg9uouSHJBmMxRVjLu5vMB
         pMprty1HCRRAQ2EmwWxjx+NisWQl4jHSVAJerppPKU7TmgTSS/Bdu/63UIP3NAZSLqe4
         sXfJHmHFFctc6hBhucpOQh0vfkMMYK/H8ugdWmsfIi4b6TRJQH9H8kThdtmOweu0I+uG
         5OMg==
X-Gm-Message-State: APjAAAUSRJipjg1lzgU9KDOYTZKwCOcLRJhSmXSiZqfWRE9tyoFcLiAq
	FmTBOZN8MzKudWHtayZc89bpeb5QBjqGCivEDbPg7XibSo1ahIZtFOxQaulP44x3GaPPjXfdeFw
	FHaGpjoFMw3RyiOWg9GYnFJI7ImwJZuxV6ZWP/UlKQJiqfMxJMVVgNJVKHH3xKQZVCw==
X-Received: by 2002:adf:eed1:: with SMTP id a17mr17789666wrp.268.1556045889293;
        Tue, 23 Apr 2019 11:58:09 -0700 (PDT)
X-Received: by 2002:adf:eed1:: with SMTP id a17mr17789628wrp.268.1556045888480;
        Tue, 23 Apr 2019 11:58:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556045888; cv=none;
        d=google.com; s=arc-20160816;
        b=IMgvKinGvZ0boG03I0NPf/7uRwwN8+3zF0wcA9pXh2qC6tjkaiVsrrOppwfr3/FGmE
         7CWZi1SiRQrU1qv9oFNJEWGBMPUQQMluX3rkhK5NdKypr26eczPT5bnJGPKgBCjA0iZN
         OOzlL8lYAxywNDPXf2cd+6SswLxX+OwFKJ7pvwxQaKcRd0y9yDqa7Qj+LWfRePc57Ani
         2zlX83arGR5AcUia1OalWY3+OEFgzW981lhDYMHMBl8gRLVzl3k8/WT964bb6Ggru1Mg
         vbXbRPwb8KtlthKfG5/C2mzlH7tNuY3MsqlYOGUOG66jw0l5kriXaGxG8szZHDUIlTmE
         vWig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=hlctpjjq5WkzFrwqOfa4m7NMkfdbQu2AODSgExXY384=;
        b=06PErSWKZLv4OB7+nq1rtCA8MRMpLs8RrQY2FXyK9Y8gtdeCvmls20uKIvY7iAmk4y
         Fewv7bhePZJY/NaoKsaC/SqB8QGpKdom7hPQS7duQpNs8mlbpduRmFEriaJp327jNsLG
         T3VR8/qz1ttEa+dT2Y7gMtFZQGlDMwPTBQJzk+OVDzfMOX4KtGEAkVUYiMDTQPht6+X8
         fttbxdcP+tW+u6Xr060b1D9gngIM3/0lwuJ39R2mxdreS9XnCGO5Id16XRTQDkPYbgPV
         3mIURY9OT2XyXIZQ237tP6qEjqMDQPO7ihfgI1xwj143aPY7ovlN10lj1EA5JG+J63OB
         59dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hMKvk3yB;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r6sor8092609wrj.44.2019.04.23.11.58.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 11:58:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hMKvk3yB;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=hlctpjjq5WkzFrwqOfa4m7NMkfdbQu2AODSgExXY384=;
        b=hMKvk3yB53/XByugJwQvmSSTZ2GCXpyrrEywyZKNl1Zn44UhyCs4+blik31s85g9mw
         RHV/ABvV6cijcPdX1p9az1+ozaxnapqmc0WNvcOWSlmG3q7c8XNebQ/c25iXlnzhzNvl
         8E52fF5Yuopw3P6EGQLvRI0JYmcIpKZbvbJ3l9WWMIkKFJj1PA008SxOUBAVaTjCe1zj
         Fbf+d8xofhHD4V7crZpqK4rEA4oMa+K3w+iAVwDabmg8OneFapU6IM9DTr2CU7qBeN4F
         aXyQupDuyjSgsJ+zyNxfCWrWufFqgNygo9XmQMAdCBk9rVrRQB57SJq272om+7xJnj6V
         iSSg==
X-Google-Smtp-Source: APXvYqw/i47UlKLXizFQ0MYcExRdFfvTSZKmwcYq4g1GZq/VAeCdbAzYZcLNedMChSXSAxI3bW7Lqeci52V+6YVoOoI=
X-Received: by 2002:a5d:670b:: with SMTP id o11mr17636092wru.125.1556045887047;
 Tue, 23 Apr 2019 11:58:07 -0700 (PDT)
MIME-Version: 1.0
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 23 Apr 2019 11:57:53 -0700
Message-ID: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
Subject: PSI vs. CPU overhead for client computing
To: Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I and others are working on improving system behavior under memory
pressure on Chrome OS.  We use zram, which swaps to a
statically-configured compressed RAM disk.  One challenge that we have
is that the footprint of our workloads is highly variable.  With zram,
we have to set the size of the swap partition at boot time.  When the
(logical) swap partition is full, we're left with some amount of RAM
usable by file and anonymous pages (we can ignore the rest).  We don't
get to control this amount dynamically.  Thus if the workload fits
nicely in it, everything works well.  If it doesn't, then the rate of
anonymous page faults can be quite high, causing large CPU overhead
for compression/decompression (as well as for other parts of the MM).

In Chrome OS and Android, we have the luxury that we can reduce
pressure by terminating processes (tab discard in Chrome OS, app kill
in Android---which incidentally also runs in parallel with Chrome OS
on some chromebooks).  To help decide when to reduce pressure, we
would like to have a reliable and device-independent measure of MM CPU
overhead.  I have looked into PSI and have a few questions.  I am also
looking for alternative suggestions.

PSI measures the times spent when some and all tasks are blocked by
memory allocation.  In some experiments, this doesn't seem to
correlate too well with CPU overhead (which instead correlates fairly
well with page fault rates).  Could this be because it includes
pressure from file page faults?  Is there some way of interpreting PSI
numbers so that the pressure from file pages is ignored?

What is the purpose of "some" and "full" in the PSI measurements?  The
chrome browser is a multi-process app and there is a lot of IPC.  When
process A is blocked on memory allocation, it cannot respond to IPC
from process B, thus effectively both processes are blocked on
allocation, but we don't see that.  Also, there are situations in
which some "uninteresting" process keep running.  So it's not clear we
can rely on "full".  Or maybe I am misunderstanding?  "Some" may be a
better measure, but again it doesn't measure indirect blockage.

The kernel contains various cpustat measurements, including some
slightly esoteric ones such as CPUTIME_GUEST and CPUTIME_GUEST_NICE.
Would adding a CPUTIME_MEM be out of the question?

Thanks!


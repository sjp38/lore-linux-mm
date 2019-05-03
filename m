Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BC1EC004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4569C2075C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 22:31:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4569C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3CC86B0005; Fri,  3 May 2019 18:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC6316B0006; Fri,  3 May 2019 18:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB3F86B0007; Fri,  3 May 2019 18:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 974C66B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 18:31:49 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y10so700886qti.22
        for <linux-mm@kvack.org>; Fri, 03 May 2019 15:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=C3UjR0+BDr0POBMiFN0YcUsgSZ80BCZAxKGo9xTFaaE=;
        b=WocpHBK97mfvssaLZ8/v+SwtnD7J+7tIOCYnMYpNc9G76x05Hh/fSLJJsJHq5QLAxC
         hw5tijIEHcsUPnCjc9ATI6hBTgsSCjUP9771rKSra93aIF2F2Y9KRqJeWFJfQytmjtvl
         a2xht1hdJInkHLAHJti6ahAOroEl94NaA5Ti0nUQEBPeyp9IG4AJIPCaLGrfVOG/nfnz
         LrINpIxedV5qwfYui+9LUwpqgV2a5BjWrSH9h2M9vbvGvXEIlNkAX0BtemZmjdKUvFGo
         kaNOvf7y0SgvlepZVYJGNbGTr1mHvBiIK977iaIlXu3yOTC47vlirHqYOYji5lgkHuVA
         ypQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVKgwOFV7uE0jxu1Lyr6E6pBjef0cQtHA31tKdvCye0o5Zh3kB8
	iFB7ldURfwxsYrEgg3ZQe46rElf1Oefcou/IGAwFhO37wJwOb5isMhJF7ptqGGEwy/uOhiO/Reo
	0W9q5YlD2xhcQ4ujO4vFOSS10FOI/uqZKprxZgoo7LR1C9nWH3yyZOd4AxhjvkJreAg==
X-Received: by 2002:a37:bd45:: with SMTP id n66mr9540997qkf.54.1556922709349;
        Fri, 03 May 2019 15:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywxjYCyJxg8OQ1cwDAOhGQbbLkusmgE+bhhQTDSF8KN6F73BU46K8vLUK26GRPyLdhUf5U
X-Received: by 2002:a37:bd45:: with SMTP id n66mr9540945qkf.54.1556922708440;
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556922708; cv=none;
        d=google.com; s=arc-20160816;
        b=OAVU7oCPNJTEoCNY8YSzVxcZlyDftsMZrqIxOFuDxd9IhORB3/CmFylNyGMVrTXVZP
         O5a0ywFH0gcyDJjIBNmK891ORV+dLkmRii6K+kOEMmTySmTQNJwVGsUg5d8vjwR3z2rr
         2ZWbALZan493VAByEVIKYOnMEoWQQr5qfxC47pVNiQmtkYt0QBmS5v86UXN2zwQNCe27
         533tUjBi+lG90LEM/nUgi4nFdswyUCB2ZvuaMt6Pt65IDsFI1Pfo2YjyTDqJdPOe8q0a
         /I9I/oMVkx3I8mO/u/32jz9ZwkqIErTPAW79NKfaDXVutFK6NMeCYpzWHevVl7xqH5w3
         GL9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=C3UjR0+BDr0POBMiFN0YcUsgSZ80BCZAxKGo9xTFaaE=;
        b=GFmTgbVZ1iCV4d+13OrXJx7xxM0g8SEUN39wUbvhXoYRh0F6pOaFGw+UYFSCIdYc60
         +n3Jv8uuXFFDFiHG0aHph1HZa8/+mNoSCeAgdT9yqNwTEoIqzjTNpMiy819GRinWH79P
         yg5a1iTa8ky5SKar1OYjJ4aEndrPRnaiAK8Y1u1Hzpq40kKgHnfhSplpfmayZDtiz40I
         Y5ymITpyMN6HR0ARG9L3JaYKtXkJIK9GR3Q41eUhDMoaGKKlNqaHfUKRG3ibduoako5Q
         kn94s9VEfxkVDQ1ybrUeqCXVWIDElVwqHevaPfmHGxx2lyKoET9K0Q090e4S7hDlEein
         /2Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p19si1091538qkk.85.2019.05.03.15.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 15:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9338081F0C;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
Received: from ultra.random (ovpn-122-217.rdu2.redhat.com [10.10.122.217])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 46E4160BFB;
	Fri,  3 May 2019 22:31:47 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/2] reapply: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Fri,  3 May 2019 18:31:44 -0400
Message-Id: <20190503223146.2312-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 03 May 2019 22:31:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

The fixes for what was originally reported as "pathological THP
behavior" we rightfully reverted to be sure not to introduced
regressions at end of a merge window after a severe regression report
from the kernel bot. We can safely re-apply them now that we had time
to analyze the problem.

The mm process worked fine, because the good fixes were eventually
committed upstream without excessive delay.

The regression reported by the kernel bot however forced us to revert
the good fixes to be sure not to introduce regressions and to give us
the time to analyze the issue further. The silver lining is that this
extra time allowed to think more at this issue and also plan for a
future direction to improve things further in terms of THP NUMA
locality.

Thank you,
Andrea

Andrea Arcangeli (2):
  Revert "Revert "mm, thp: consolidate THP gfp handling into
    alloc_hugepage_direct_gfpmask""
  Revert "mm, thp: restore node-local hugepage allocations"

 include/linux/gfp.h       | 12 +++------
 include/linux/mempolicy.h |  2 ++
 mm/huge_memory.c          | 51 ++++++++++++++++++++++++---------------
 mm/mempolicy.c            | 34 +++-----------------------
 mm/shmem.c                |  2 +-
 5 files changed, 42 insertions(+), 59 deletions(-)


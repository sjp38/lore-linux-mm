Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B9C3C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5581217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:33:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BfXwwjAu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5581217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C10A26B0291; Mon, 26 Aug 2019 19:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9A816B0292; Mon, 26 Aug 2019 19:33:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A874C6B0293; Mon, 26 Aug 2019 19:33:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 85C386B0291
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:33:18 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3B5B9180AD804
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:33:18 +0000 (UTC)
X-FDA: 75866182476.22.skirt87_39e4d6c255917
X-HE-Tag: skirt87_39e4d6c255917
X-Filterd-Recvd-Size: 8847
Received: from mail-qt1-f202.google.com (mail-qt1-f202.google.com [209.85.160.202])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:33:17 +0000 (UTC)
Received: by mail-qt1-f202.google.com with SMTP id g33so19153579qtc.14
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:33:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5FDOwwCe+APWdEQQqNbBpE6iIki5NU5vXPefDHikBmg=;
        b=BfXwwjAuhrLzwyV49VnJL7NxDepEgABTklx9qhc6rCK5F1w2xw2LFgmzTWfEAHiPTF
         c5v46KJZa6ts7LaEAl2UEDScmWBYH5FdRRkicG6JhCd5gzMC/MBrJM+gYNO8Y0DVWbd5
         NXpoHq7M83Am1Y0GWNerd7Jl1ueGsflkoKLPII48XaDmWf1gZAsG9uA8s1QmT0b9GiBR
         N55L5aExlS7kaRIdXdaPfI1XlO+g1o6LMycyymR5h1zGtC9eyWIzaUH81AY7A3AqGLvk
         we6DYp4QKXYWKwHLDCaThtFG284KWl3dBsOd8oJmCEJHfUQZs3Chk6Cz9lgq6vY8+BVj
         jxoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=5FDOwwCe+APWdEQQqNbBpE6iIki5NU5vXPefDHikBmg=;
        b=HA5SZxCBf+glSs1maFdWZWirbajtg7uMl65ueA55N3RtacR0Rdf5F0Sl6o3aktzQz8
         HSz24TxwTkicqbXKTcx1hyok8vy+GBPhKzEAt1zblyjw6xQ+VpZY7Q6Gj3m2rW5Po54m
         kpX/zLeFaZMiw1d9em6XXOH9fX42ifuzjoKhxaQWew9abjAdn8T7pP3pmOjkCKsLAtwK
         RFsluw4iTiuyOhkyHWYxsy8na9JJENGnwBBdYWss+xu6lsf+NTAoI4/J6Pm8uvxq3179
         l/oYlWLBKGM0Woa8QcSwt1IRiUUO5ABwv0AdmjzChA3MaI3dJXTMIQm1p+c77fThkHis
         4zmg==
X-Gm-Message-State: APjAAAU3pFWnMXkxvlzu1Yf0BIwl1xJ9Hd4FBiRF2wFUhyWREXmX2wYj
	ClyGdA0Bc0nn9MHiZvvicdke7uNyLWmeo3jK+Q==
X-Google-Smtp-Source: APXvYqyDImAPzfr0N58wa/tY2W7Edq/krF5d6f1tRQcHXjvREDYlfn3oZlUNIZ7WqjjdFcG1GxtewDdCNH22t72/9w==
X-Received: by 2002:ad4:45d3:: with SMTP id v19mr17564793qvt.90.1566862396925;
 Mon, 26 Aug 2019 16:33:16 -0700 (PDT)
Date: Mon, 26 Aug 2019 16:32:40 -0700
In-Reply-To: <20190826233240.11524-1-almasrymina@google.com>
Message-Id: <20190826233240.11524-7-almasrymina@google.com>
Mime-Version: 1.0
References: <20190826233240.11524-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.187.g17f5b7556c-goog
Subject: [PATCH v3 6/6] hugetlb_cgroup: Add hugetlb_cgroup reservation docs
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add docs for how to use hugetlb_cgroup reservations, and their behavior.

---
 .../admin-guide/cgroup-v1/hugetlb.rst         | 84 ++++++++++++++++---
 1 file changed, 73 insertions(+), 11 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v1/hugetlb.rst b/Documentation/admin-guide/cgroup-v1/hugetlb.rst
index a3902aa253a96..cc6eb859fc722 100644
--- a/Documentation/admin-guide/cgroup-v1/hugetlb.rst
+++ b/Documentation/admin-guide/cgroup-v1/hugetlb.rst
@@ -2,13 +2,6 @@
 HugeTLB Controller
 ==================

-The HugeTLB controller allows to limit the HugeTLB usage per control group and
-enforces the controller limit during page fault. Since HugeTLB doesn't
-support page reclaim, enforcing the limit at page fault time implies that,
-the application will get SIGBUS signal if it tries to access HugeTLB pages
-beyond its limit. This requires the application to know beforehand how much
-HugeTLB pages it would require for its use.
-
 HugeTLB controller can be created by first mounting the cgroup filesystem.

 # mount -t cgroup -o hugetlb none /sys/fs/cgroup
@@ -28,10 +21,14 @@ process (bash) into it.

 Brief summary of control files::

- hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
- hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
- hugetlb.<hugepagesize>.usage_in_bytes     # show current usage for "hugepagesize" hugetlb
- hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
+ hugetlb.<hugepagesize>.reservation_limit_in_bytes     # set/show limit of "hugepagesize" hugetlb reservations
+ hugetlb.<hugepagesize>.reservation_max_usage_in_bytes # show max "hugepagesize" hugetlb reservations recorded
+ hugetlb.<hugepagesize>.reservation_usage_in_bytes     # show current reservations for "hugepagesize" hugetlb
+ hugetlb.<hugepagesize>.reservation_failcnt            # show the number of allocation failure due to HugeTLB reservation limit
+ hugetlb.<hugepagesize>.limit_in_bytes                 # set/show limit of "hugepagesize" hugetlb faults
+ hugetlb.<hugepagesize>.max_usage_in_bytes             # show max "hugepagesize" hugetlb  usage recorded
+ hugetlb.<hugepagesize>.usage_in_bytes                 # show current usage for "hugepagesize" hugetlb
+ hugetlb.<hugepagesize>.failcnt                        # show the number of allocation failure due to HugeTLB usage limit

 For a system supporting three hugepage sizes (64k, 32M and 1G), the control
 files include::
@@ -40,11 +37,76 @@ files include::
   hugetlb.1GB.max_usage_in_bytes
   hugetlb.1GB.usage_in_bytes
   hugetlb.1GB.failcnt
+  hugetlb.1GB.reservation_limit_in_bytes
+  hugetlb.1GB.reservation_max_usage_in_bytes
+  hugetlb.1GB.reservation_usage_in_bytes
+  hugetlb.1GB.reservation_failcnt
   hugetlb.64KB.limit_in_bytes
   hugetlb.64KB.max_usage_in_bytes
   hugetlb.64KB.usage_in_bytes
   hugetlb.64KB.failcnt
+  hugetlb.64KB.reservation_limit_in_bytes
+  hugetlb.64KB.reservation_max_usage_in_bytes
+  hugetlb.64KB.reservation_usage_in_bytes
+  hugetlb.64KB.reservation_failcnt
   hugetlb.32MB.limit_in_bytes
   hugetlb.32MB.max_usage_in_bytes
   hugetlb.32MB.usage_in_bytes
   hugetlb.32MB.failcnt
+  hugetlb.32MB.reservation_limit_in_bytes
+  hugetlb.32MB.reservation_max_usage_in_bytes
+  hugetlb.32MB.reservation_usage_in_bytes
+  hugetlb.32MB.reservation_failcnt
+
+
+1. Reservation limits
+
+The HugeTLB controller allows to limit the HugeTLB reservations per control
+group and enforces the controller limit at reservation time. Reservation limits
+are superior to Page fault limits (see section 2), since Reservation limits are
+enforced at reservation time, and never causes the application to get SIGBUS
+signal. Instead, if the application is violating its limits, then it gets an
+error on reservation time, i.e. the mmap or shmget return an error.
+
+
+2. Page fault limits
+
+The HugeTLB controller allows to limit the HugeTLB usage (page fault) per
+control group and enforces the controller limit during page fault. Since HugeTLB
+doesn't support page reclaim, enforcing the limit at page fault time implies
+that, the application will get SIGBUS signal if it tries to access HugeTLB
+pages beyond its limit. This requires the application to know beforehand how
+much HugeTLB pages it would require for its use.
+
+
+3. Caveats with shared memory
+
+a. Charging and uncharging:
+
+For shared hugetlb memory, both hugetlb reservation and usage (page faults) are
+charged to the first task that causes the memory to be reserved or faulted,
+and all subsequent uses of this reserved or faulted memory is done without
+charging.
+
+Shared hugetlb memory is only uncharged when it is unreseved or deallocated.
+This is usually when the hugetlbfs file is deleted, and not when the task that
+caused the reservation or fault has exited.
+
+b. Interaction between reservation limit and fault limit.
+
+Generally, it's not recommended to set both of the reservation limit and fault
+limit in a cgroup. For private memory, the fault usage cannot exceed the
+reservation usage, so if you set both, one of those limits will be useless.
+
+For shared memory, a cgroup's fault usage may be greater than its reservation
+usage, so some care needs to be taken. Consider this example:
+
+- Task A reserves 4 pages in a shared hugetlbfs file. Cgroup A will get
+  4 reservations charged to it and no faults charged to it.
+- Task B reserves and faults the same 4 pages as Task A. Cgroup B will get no
+  reservation charge, but will get charged 4 faulted pages. If Cgroup B's limit
+  is less than 4, then Task B will get a SIGBUS.
+
+For the above scenario, it's not recommended for the userspace to set both
+reservation limits and fault limits, but it is still allowed to in case it sees
+some use for it.
--
2.23.0.187.g17f5b7556c-goog


Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D9DAC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2A322DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f0fycqMF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2A322DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FE156B02CF; Wed, 21 Aug 2019 10:59:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AED56B02D0; Wed, 21 Aug 2019 10:59:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276CF6B02D1; Wed, 21 Aug 2019 10:59:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 072DC6B02CF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:59:28 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A3914181AC540
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:28 +0000 (UTC)
X-FDA: 75846743616.24.pump21_52a8d50d3b122
X-HE-Tag: pump21_52a8d50d3b122
X-Filterd-Recvd-Size: 10598
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:27 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w16so1598834pfn.7
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:59:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=Z5zNV+aGEXnZe0+CPgdtnFJ8dRf/r2ygP8Iohve0Rps=;
        b=f0fycqMFGS1JWxp1KhvwIftJwqDZPus1tTQemthJDQYeojm77cFV7cVWmH5S1Gac4V
         EprUkqhJletcvmlAj1qn9J3/X5GtO5Ba1MJjYPyhBg17L3ymOQILNaNynrz322LN9KMn
         ozCbINmOAl05/syfAkDa8J2ppNOPXR4kQr+k8VytHd+4Bj12QnYc2FtR5jx1lUEu2rFB
         XLF0YeUfPnVuaBtNPkigEZnTKdzINmRTFb6yG00JjThyNla6wNXxc8xX33tMWJnhVVry
         xw3dNLW7LJth/U7S71Mdl+g5ukquPnozyRuUpAGh3hQxXfvMgPjg1d4u+jw6e5tUaezs
         w0WA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=Z5zNV+aGEXnZe0+CPgdtnFJ8dRf/r2ygP8Iohve0Rps=;
        b=VrsdqJiTtqEr31LL4QhjEZdxp1LEP5Qlp10PpguWfXAmmHk5DEdkHJEBpcbvk7fXQK
         xgscctyGEGpe9cFEu4Crz0nC9boNTKnFO9eZXAy4i6gRI+ajXwr1OcXd7wg2VRPvqE+C
         8lKt9CkSjP1ERHQ1kYQ+cr+1nqbXsZy8XGMnL1szpDyP8045MfHcRZ7nYcICNzw8bQZp
         EgrOg7mVVVTdq66zmgmhpzWygbS0uUWq63GWV1P5KtNgvERm1S3Pj2hB1uNQN0LpL5xU
         MGelI7LLkB74Nq7loYGHuN3AnWcIeXeVgJv8VS6263s45QorHE/kyqDswxFEkz5qlTvq
         dh9Q==
X-Gm-Message-State: APjAAAU1dDXQbheStSNzHLXuWX7xq8vLfaYrIzgruLRyXH/lTKKrPI9H
	YkaGXrg0zznHCNnCGr7MkF8=
X-Google-Smtp-Source: APXvYqzrFyVlorWkueXx9HRBuLKcOcy2Opun+O4OOr1HVzfU2JfHa3PQ1/39vsylKSV3Xcp4yieOtQ==
X-Received: by 2002:a17:90a:8991:: with SMTP id v17mr410994pjn.120.1566399566511;
        Wed, 21 Aug 2019 07:59:26 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id f12sm22513826pgo.85.2019.08.21.07.59.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 07:59:25 -0700 (PDT)
Subject: [PATCH v6 0/6] mm / virtio: Provide support for unused page
 reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 21 Aug 2019 07:59:24 -0700
Message-ID: <20190821145806.20926.22448.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series provides an asynchronous means of reporting to a hypervisor
that a guest page is no longer in use and can have the data associated
with it dropped. To do this I have implemented functionality that allows
for what I am referring to as unused page reporting

The functionality for this is fairly simple. When enabled it will allocate
statistics to track the number of reported pages in a given free area.
When the number of free pages exceeds this value plus a high water value,
currently 32, it will begin performing page reporting which consists of
pulling pages off of free list and placing them into a scatter list. The
scatterlist is then given to the page reporting device and it will perform
the required action to make the pages "reported", in the case of
virtio-balloon this results in the pages being madvised as MADV_DONTNEED
and as such they are forced out of the guest. After this they are placed
back on the free list, and an additional bit is added if they are not
merged indicating that they are a reported buddy page instead of a
standard buddy page. The cycle then repeats with additional non-reported
pages being pulled until the free areas all consist of reported pages.

I am leaving a number of things hard-coded such as limiting the lowest
order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
determine what the limit is on how many pages it wants to allocate to
process the hints. The upper limit for this is based on the size of the
queue used to store the scattergather list.

My primary testing has just been to verify the memory is being freed after
allocation by running memhog 40g on a 40g guest and watching the total
free memory via /proc/meminfo on the host. With this I have verified most
of the memory is freed after each iteration. As far as performance I have
been mainly focusing on the will-it-scale/page_fault1 test running with
16 vcpus. I have modified it to use Transparent Huge Pages. With this I
see almost no difference, -0.08%, with the patches applied and the feature
disabled. I see a regression of -0.86% with the feature enabled, but the
madvise disabled in the hypervisor due to a device being assigned. With
the feature fully enabled I see a regression of -3.27% versus the baseline
without these patches applied. In my testing I found that most of the
overhead was due to the page zeroing that comes as a result of the pages
having to be faulted back into the guest.

One side effect of these patches is that the guest becomes much more
resilient in terms of NUMA locality. With the pages being freed and then
reallocated when used it allows for the pages to be much closer to the
active thread, and as a result there can be situations where this patch
set will out-perform the stock kernel when the guest memory is not local
to the guest vCPUs. To avoid that in my testing I set the affinity of all
the vCPUs and QEMU instance to the same node.

Changes from the RFC:
https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
Moved aeration requested flag out of aerator and into zone->flags.
Moved boundary out of free_area and into local variables for aeration.
Moved aeration cycle out of interrupt and into workqueue.
Left nr_free as total pages instead of splitting it between raw and aerated.
Combined size and physical address values in virtio ring into one 64b value.

Changes from v1:
https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
Dropped "waste page treatment" in favor of "page hinting"
Renamed files and functions from "aeration" to "page_hinting"
Moved from page->lru list to scatterlist
Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sync
Virtio now uses scatterlist directly instead of intermediate array
Moved stats out of free_area, now in separate area and pointed to from zone
Merged patch 5 into patch 4 to improve review-ability
Updated various code comments throughout

Changes from v2:
https://lore.kernel.org/lkml/20190724165158.6685.87228.stgit@localhost.localdomain/
Dropped "page hinting" in favor of "page reporting"
Renamed files from "hinting" to "reporting"
Replaced "Hinted" page type with "Reported" page flag
Added support for page poisoning while hinting is active
Add QEMU patch that implements PAGE_POISON feature

Changes from v3:
https://lore.kernel.org/lkml/20190801222158.22190.96964.stgit@localhost.localdomain/
Added mutex lock around page reporting startup and shutdown
Fixed reference to "page aeration" in patch 2
Split page reporting function bit out into separate QEMU patch
Limited capacity of scatterlist to vq size - 1 instead of vq size
Added exception handling for case of virtio descriptor allocation failure

Changes from v4:
https://lore.kernel.org/lkml/20190807224037.6891.53512.stgit@localhost.localdomain/
Replaced spin_(un)lock with spin_(un)lock_irq in page_reporting_cycle()
Dropped if/continue for ternary operator in page_reporting_process()
Added checks for isolate and cma types to for_each_reporting_migratetype_order
Added virtio-dev, Michal Hocko, and Oscar Salvador to to:/cc:
Rebased on latest linux-next and QEMU git trees

Changes from v5:
https://lore.kernel.org/lkml/20190812213158.22097.30576.stgit@localhost.localdomain/
Replaced spin_(un)lock with spin_(un)lock_irq in page_reporting_startup()
Updated shuffle code to use "shuffle_pick_tail" and updated patch description
Dropped storage of order and migratettype while page is being reported
Used get_pfnblock_migratetype to determine migratetype of page
Renamed put_reported_page to free_reported_page, added order as argument
Dropped check for CMA type as I believe we should be reporting those
Added code to allow moving of reported pages into and out of isolation
Defined page reporting order as minimum of Huge Page size vs MAX_ORDER - 1
Cleaned up use of static branch usage for page_reporting_notify_enabled

---

Alexander Duyck (6):
      mm: Adjust shuffle code to allow for future coalescing
      mm: Move set/get_pcppage_migratetype to mmzone.h
      mm: Use zone and order instead of free area in free_list manipulators
      mm: Introduce Reported pages
      virtio-balloon: Pull page poisoning config out of free page hinting
      virtio-balloon: Add support for providing unused page reports to host


 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   84 ++++++++-
 include/linux/mmzone.h              |  124 ++++++++-----
 include/linux/page-flags.h          |   11 +
 include/linux/page_reporting.h      |  177 ++++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/internal.h                       |   18 ++
 mm/memory_hotplug.c                 |    1 
 mm/page_alloc.c                     |  216 ++++++++++++++++-------
 mm/page_reporting.c                 |  336 +++++++++++++++++++++++++++++++++++
 mm/shuffle.c                        |   40 +++-
 mm/shuffle.h                        |   12 +
 14 files changed, 896 insertions(+), 131 deletions(-)
 create mode 100644 include/linux/page_reporting.h
 create mode 100644 mm/page_reporting.c

--


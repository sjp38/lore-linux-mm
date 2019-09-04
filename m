Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C9CC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:10:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2376722CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:10:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZzQNV8kA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2376722CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACFA86B0008; Wed,  4 Sep 2019 11:10:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5A006B000A; Wed,  4 Sep 2019 11:10:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9203F6B000C; Wed,  4 Sep 2019 11:10:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5E66B0008
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:10:28 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BB74A55F8B
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:10:27 +0000 (UTC)
X-FDA: 75897574494.23.top40_7854e033a4523
X-HE-Tag: top40_7854e033a4523
X-Filterd-Recvd-Size: 10939
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:10:26 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id w10so11408857pgj.7
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 08:10:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=J2tFQpQAldqgZlKB5LupCO5ngfjUyWGYvS66dt/H1ec=;
        b=ZzQNV8kASJ4xpTd7HZFPhRYirN94yMl7+GhAo/XuIOfYraA91weugvO/OlQfU3YaAo
         h6RQpfsLGHbKwicknjT9CMEywHlwYBwGEvzMRMXb+H6422PAlbNaTX0h+cDapWvVlt7g
         fi4NuuJVVp34+TcQRaI09XNZyTSCIeO1j0KMUS9vvhu7ZNMKzH6V7yW72qP0gR/1C6rO
         vYwDUSkDA/3vp6h+Og/CeGA6gv0H4I8eF/HqkDu9E5nTnReOtw4nv2HIc/3iQSEo2z4M
         RqMcoWltTdciRv6fKcuPyQh73ImKGQE2xXwI4wwobPKC+qYJRPAweDjuY5J3xaPYpRJR
         gunw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=J2tFQpQAldqgZlKB5LupCO5ngfjUyWGYvS66dt/H1ec=;
        b=qoFmnBBNdaq61sZF8D1k858tDsz9etuhwMFTTTgc8AKy7/mLbSwet09weY6mmELakl
         R6nK4sYMPXsKGZOGlrg5/50HR5GKTH7r6MsB9o5Js6I7uZ/35cXq7iLmHRj0554uNl+1
         LcXsZVg4NYCoZme9H4x541WGt6O+aHm2SH8dETzqZuMx66WgUAIynLzFLgxeZJsETXs2
         XO4so1lsfhfF7xxeJcaPC20ONMJzNPjS/bqKiRzj62exBvP0bz2ZJVcbeKj0wdLTcfd6
         xAGxo/b6zbVFqGTvF6jtNo5dk+628xulmg7efXLX/3tRowY7BSx/N0F7Za8W0pZ8PKU0
         dubA==
X-Gm-Message-State: APjAAAW7brEOICsH+OIqMCuFWToSXjwkhbecU7H6yvWGbWMf7j3arHuy
	UaWdMzuN1MVZl2HGO32Rj5Y=
X-Google-Smtp-Source: APXvYqx+WKEu5kZbeBnFWxNU4xgdmRXuCvXOlsEfBHqA7lBWZDwZpdD7lx1MX7lPKg9wgI86ymZ4ow==
X-Received: by 2002:a17:90a:a896:: with SMTP id h22mr5514847pjq.1.1567609825568;
        Wed, 04 Sep 2019 08:10:25 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id y25sm22561609pfm.95.2019.09.04.08.10.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 08:10:25 -0700 (PDT)
Subject: [PATCH v7 0/6] mm / virtio: Provide support for unused page
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
Date: Wed, 04 Sep 2019 08:10:24 -0700
Message-ID: <20190904150920.13848.32271.stgit@localhost.localdomain>
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

Changes from v6:
https://lore.kernel.org/lkml/20190821145806.20926.22448.stgit@localhost.localdomain/
Rebased on linux-next for 20190903
Added jump label to __page_reporting_request so we release RCU read lock
Removed "- 1" from capacity limit based on virtio ring
Added code to verify capacity is non-zero or return error on startup

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
 mm/page_alloc.c                     |  216 ++++++++++++++++------
 mm/page_reporting.c                 |  340 +++++++++++++++++++++++++++++++++++
 mm/shuffle.c                        |   40 ++--
 mm/shuffle.h                        |   12 +
 14 files changed, 900 insertions(+), 131 deletions(-)
 create mode 100644 include/linux/page_reporting.h
 create mode 100644 mm/page_reporting.c

--


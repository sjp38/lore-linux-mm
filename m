Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43D13C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB39D217F4
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TG77Pryg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB39D217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EC3C6B0003; Mon, 12 Aug 2019 17:33:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69D306B0005; Mon, 12 Aug 2019 17:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B30A6B0006; Mon, 12 Aug 2019 17:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 395436B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:33:22 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E49682C8B
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:21 +0000 (UTC)
X-FDA: 75815077002.04.vein80_577fc38d4d714
X-HE-Tag: vein80_577fc38d4d714
X-Filterd-Recvd-Size: 9837
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:21 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id z14so12899382pga.5
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:33:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=KTa8+wycQ8v6otm1cx7E8dMkbjnylPTuxFsohuMVZGU=;
        b=TG77PrygnPJHYs018G1Y4vmMjWMfFU0KIBllkNn/fhq8z9v/GvFYQ79ixTOuIe7IGo
         cnVMHPFnE9qMVyn7hjZSnTnWnbujTBcsBed1kinRcH9gUUYxISeAWuP3PMP4J57NM/W+
         318e/+BtVFbW0NODmnx39DtwZYpEH3u8pLA5xx0mBrjtM8AYP+skxLdRPwOhhCqODYFK
         /6bTQYvTvwq0XLF76UII3RjRgTBGCrUggzDgbnMOgAjFmrsVMedEE+J//WtznAqV1dLY
         bf+GAj7djo754PYg4T/pW0wjGp1UM7CoV1oKVn7Qvk2OB9itE4LZRA9E7NlEptvIzN39
         1Gbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=KTa8+wycQ8v6otm1cx7E8dMkbjnylPTuxFsohuMVZGU=;
        b=NMICQv4HqtuZG0+ixQa6iGG8+Cy9snKohCVexPL3XhKMEr7Skx5v3NNbRRLfK1pkBm
         FL22I2kf873/kLWPh2YTXDUWAqpoJkBndxJISOBnSJNdbussVfpnqW3ibJ/aYZed/cJw
         fh5I9RmlnVJWWIGfB2KolS6jzWSbSZPep0q73ZY1yHDS4qP0LifFKXXJXToyohyp3XDo
         8NNe6JJQIf8Tq0TYbops4xtN9q8SV7ZPNDGEOWDZ2Doofxo3AhlJIAC7SmCZzZiWWkrT
         LzpFWOHnvK7RSGi8rVe0S6HPq2+Urgc1I9YQXwPcZd77ZFsTFlJXONRoHaciIFukyers
         e73w==
X-Gm-Message-State: APjAAAWfYHUcVt/zJ28ICAxtbH9YRBlP9fqjPLGknfsEE17Fj5nbZxGk
	VvjDHqQk0T/X7Pbv9jVWFUY=
X-Google-Smtp-Source: APXvYqzt8ksLb5uAyzkdXWDnkN3SNBn2VmAoNK4BcK21halKh74KkuUhiEpPWUhkVtVOcuYev4nIRA==
X-Received: by 2002:a65:680b:: with SMTP id l11mr31944901pgt.35.1565645599868;
        Mon, 12 Aug 2019 14:33:19 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id w2sm607692pjr.27.2019.08.12.14.33.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 14:33:19 -0700 (PDT)
Subject: [PATCH v5 0/6] mm / virtio: Provide support for unused page
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
Date: Mon, 12 Aug 2019 14:33:18 -0700
Message-ID: <20190812213158.22097.30576.stgit@localhost.localdomain>
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

---

Alexander Duyck (6):
      mm: Adjust shuffle code to allow for future coalescing
      mm: Move set/get_pcppage_migratetype to mmzone.h
      mm: Use zone and order instead of free area in free_list manipulators
      mm: Introduce Reported pages
      virtio-balloon: Pull page poisoning config out of free page hinting
      virtio-balloon: Add support for providing unused page reports to host


 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   84 +++++++++-
 include/linux/mmzone.h              |  116 ++++++++-----
 include/linux/page-flags.h          |   11 +
 include/linux/page_reporting.h      |  138 ++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/internal.h                       |   18 ++
 mm/memory_hotplug.c                 |    1 
 mm/page_alloc.c                     |  238 ++++++++++++++++++++-------
 mm/page_reporting.c                 |  308 +++++++++++++++++++++++++++++++++++
 mm/shuffle.c                        |   24 ---
 mm/shuffle.h                        |   32 ++++
 14 files changed, 839 insertions(+), 139 deletions(-)
 create mode 100644 include/linux/page_reporting.h
 create mode 100644 mm/page_reporting.c

--


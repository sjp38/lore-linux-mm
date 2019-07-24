Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C960C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 251C621926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:56:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eWuAulp7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 251C621926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903B66B000A; Wed, 24 Jul 2019 12:56:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BC306B000C; Wed, 24 Jul 2019 12:56:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CA0C8E0002; Wed, 24 Jul 2019 12:56:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47EB16B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:56:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so24455500pld.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:56:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=PhVb6RN1Ss2cdB2PwVe0HtBm8bfHqYHCMNa/n92glxA=;
        b=g5iYvoDeNdKPwBs6D2hw0tlt4MHT+9ML/Cgsmi/wmBf0Xb1JG+sOCH7wPSKn5JSJGv
         jRsQzVIQstqjYECc1xAmbY9cXgPJJB+33OV8pRQftQA3IphiWMqtg83MsMlpxS/9EVmr
         aasQ8YKknaT3Z+HPPqnf/GbSQwxpc9op1J447nx5QCOnmdvrXhAGPqc9KL9o9or+TXrI
         9ux/R5mO0QaX/wlNMUz51kxkM4AmAcI+sWq+/SkziUpldLKJpXO5L4hoLqGcrx13s2sg
         9KsT4iqHMPQyrTkIWvlT16YPFuog+dGzwrOCnuR8yZZmd6MYvoH5liL1/ucfyJ7qu8Ou
         EGvA==
X-Gm-Message-State: APjAAAXpIFKPTg+DlBLeFbQoeQMpIrfzIVtld87h6YS5iPsoXYjI0D9c
	r18fQheqIp1upDAG9vBVDdzkDz/zIFRl0w6jxnR4r/TVy25m6Xi6ZYzsjDhA5UGBnYONAVhi3mu
	Wk5VaoiVfpEBv7Ur3SfulYaZbcgwzVECj7VJyraFCLC32Q97I3zHdun/9Nh2TyYhaXQ==
X-Received: by 2002:a63:dd0b:: with SMTP id t11mr41930013pgg.410.1563987372427;
        Wed, 24 Jul 2019 09:56:12 -0700 (PDT)
X-Received: by 2002:a63:dd0b:: with SMTP id t11mr41929954pgg.410.1563987371401;
        Wed, 24 Jul 2019 09:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563987371; cv=none;
        d=google.com; s=arc-20160816;
        b=aeUY5RnRLJ+lr1nhH4puGShNadfp7Oj6YI0ZUjyjO1RS3qljoT5+trcvoMavg5Ud4F
         qXxokd8sNvn9HlE151UyCEF3eNOd9x6wF03+Ounri0UMJ6ydVCn/6K9Y7cB/625hIDoc
         qYXuJasiJwBu4ScVAZgAx39iA90i/7AQzEgFhS5q3MhAt8W2jm7oSl75h9bkVglhsB7m
         nqZDjO4tp4WhDyADKdYdswf0miwGFSlb2gAVeYRGrN4WAlop8MMnzpKnDnz6jYzYLBes
         Ucpbcalz+W1fc61R/ozyHaubdcMVnaxR364OR4XQObmcUCWyS51hpqMGIUY5MYM1pX88
         ElzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=PhVb6RN1Ss2cdB2PwVe0HtBm8bfHqYHCMNa/n92glxA=;
        b=FXqDAhBCQaqAY7Jn/LZbrtkrrj5YqiGkADafRnOZp9KPKQnRKgwPxOxUKsaqpcjcPr
         wiFPkv6nbmn3okNYGN61m9MKlW+c+HatzMaPXqXiLSTV1CHGbduQKQUGEDINLI/wS2QC
         rO3RAjADZzyaPI499qWQmgnGhD3TRVGnaZZB4CfUKpadNDzBcUM2YCeCdb2vPHXmY1CA
         ws/pqHDeEIgrLKQTb+/rMxzpOyuk7sErg11PbkRsRAD5oGSxrGJJM1Cn2ayDGV8GUQRm
         4SBg+XvDGJUhx3QIbim0teHIFFdqQA2Rx7F4dgjBlnOwJcQoTn/V9OnMk00oYRDR8o2W
         8Bng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eWuAulp7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s24sor7385832pgm.81.2019.07.24.09.56.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 09:56:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eWuAulp7;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=PhVb6RN1Ss2cdB2PwVe0HtBm8bfHqYHCMNa/n92glxA=;
        b=eWuAulp7lVJApkFKE01P2svmwkQSz+xZKBk4ILTbKSTUXwG6JPCNOThPtpZipJJywM
         fuowmbFRGkDa4VN4iOGrb0ez3a8/f+PT1HLrK2ycWYe5GcKy2PJft0JrgMFUQkF2bieb
         ynYDQR9OITwdZktFzeBHzKB6sV1c5twRJTSBsPEnRwP0UGx9fodzsh0b20sSvwmvC2Xi
         cvRh0qC/t6520YdzswKjIplH1tFaH3L80ZrxvZWu8xdOgdPTNrqVsRj2JinU6lrnNAps
         IQlQV0ZJRP+Jdf9NjxJl5OKKqIQodIiqsGrqolvaBYG528KyU0W6Dhi7ELw8W4uH1nTa
         KROQ==
X-Google-Smtp-Source: APXvYqy5FhBKIOIqEhIwqKISuGQ+P1R0oDCuSk0WbIIGBn5tah6kKqrwZ+sY9jBZWmTnJ8zO8szXNw==
X-Received: by 2002:a63:f304:: with SMTP id l4mr81474308pgh.66.1563987370874;
        Wed, 24 Jul 2019 09:56:10 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id r61sm61815112pjb.7.2019.07.24.09.56.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 09:56:10 -0700 (PDT)
Subject: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 09:54:02 -0700
Message-ID: <20190724165158.6685.87228.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series provides an asynchronous means of hinting to a hypervisor
that a guest page is no longer in use and can have the data associated
with it dropped. To do this I have implemented functionality that allows
for what I am referring to as page hinting

The functionality for this is fairly simple. When enabled it will allocate
statistics to track the number of hinted pages in a given free area. When
the number of free pages exceeds this value plus a high water value,
currently 32, it will begin performing page hinting which consists of
pulling pages off of free list and placing them into a scatter list. The
scatterlist is then given to the page hinting device and it will perform
the required action to make the pages "hinted", in the case of
virtio-balloon this results in the pages being madvised as MADV_DONTNEED
and as such they are forced out of the guest. After this they are placed
back on the free list, and an additional bit is added if they are not
merged indicating that they are a hinted buddy page instead of a standard
buddy page. The cycle then repeats with additional non-hinted pages being
pulled until the free areas all consist of hinted pages.

I am leaving a number of things hard-coded such as limiting the lowest
order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
determine what the limit is on how many pages it wants to allocate to
process the hints.

My primary testing has just been to verify the memory is being freed after
allocation by running memhog 79g on a 80g guest and watching the total
free memory via /proc/meminfo on the host. With this I have verified most
of the memory is freed after each iteration. As far as performance I have
been mainly focusing on the will-it-scale/page_fault1 test running with
16 vcpus. With that I have seen at most a 2% difference between the base
kernel without these patches and the patches with virtio-balloon disabled.
With the patches and virtio-balloon enabled with hinting the results
largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
drop in performance as I approached 16 threads, however on the the lastest
linux-next kernel I saw roughly a 4% to 5% improvement in performance for
all tests with 8 or more threads. I believe the difference seen is due to
the overhead for faulting pages back into the guest and zeroing of memory.

Patch 4 is a bit on the large side at about 600 lines of change, however
I really didn't see a good way to break it up since each piece feeds into
the next. So I couldn't add the statistics by themselves as it didn't
really make sense to add them without something that will either read or
increment/decrement them, or add the Hinted state without something that
would set/unset it. As such I just ended up adding the entire thing as
one patch. It makes it a bit bigger but avoids the issues in the previous
set where I was referencing things before they had been added.

Changes from the RFC:
https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
Moved aeration requested flag out of aerator and into zone->flags.
Moved bounary out of free_area and into local variables for aeration.
Moved aeration cycle out of interrupt and into workqueue.
Left nr_free as total pages instead of splitting it between raw and aerated.
Combined size and physical address values in virtio ring into one 64b value.

Changes from v1:
https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
Dropped "waste page treatment" in favor of "page hinting"
Renamed files and functions from "aeration" to "page_hinting"
Moved from page->lru list to scatterlist
Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sync
Virtio now uses scatterlist directly instead of intermedate array
Moved stats out of free_area, now in seperate area and pointed to from zone
Merged patch 5 into patch 4 to improve reviewability
Updated various code comments throughout

---

Alexander Duyck (5):
      mm: Adjust shuffle code to allow for future coalescing
      mm: Move set/get_pcppage_migratetype to mmzone.h
      mm: Use zone and order instead of free area in free_list manipulators
      mm: Introduce Hinted pages
      virtio-balloon: Add support for providing page hints to host


 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   47 ++++++
 include/linux/mmzone.h              |  116 ++++++++------
 include/linux/page-flags.h          |    8 +
 include/linux/page_hinting.h        |  139 ++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/internal.h                       |   18 ++
 mm/memory_hotplug.c                 |    1 
 mm/page_alloc.c                     |  238 ++++++++++++++++++++--------
 mm/page_hinting.c                   |  298 +++++++++++++++++++++++++++++++++++
 mm/shuffle.c                        |   24 ---
 mm/shuffle.h                        |   32 ++++
 14 files changed, 796 insertions(+), 133 deletions(-)
 create mode 100644 include/linux/page_hinting.h
 create mode 100644 mm/page_hinting.c

--


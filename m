Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDE60C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:23:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4D6B2070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:23:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4D6B2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D5F96B0271; Fri,  6 Sep 2019 11:23:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587166B0272; Fri,  6 Sep 2019 11:23:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49E2F6B0273; Fri,  6 Sep 2019 11:23:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 299DD6B0271
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:23:16 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C0B2C181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:23:15 +0000 (UTC)
X-FDA: 75904864350.02.dolls43_3974013b7ea12
X-HE-Tag: dolls43_3974013b7ea12
X-Filterd-Recvd-Size: 11715
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:23:14 +0000 (UTC)
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7E15F7FDFA
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:23:13 +0000 (UTC)
Received: by mail-qk1-f198.google.com with SMTP id x77so6814141qka.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 08:23:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=+0qfYdENvJZS+7XOB5nUvg22BeaGDp5RFB+PXPHe2sA=;
        b=nNSzqijodN/P1hMWOHxbStu4WqBinhw++4PvREH1HIzHyCXtI/fY2sndsQ4Ur6woxV
         hncSXn7ZmTcwqH2Df7WZz7wIbNk18XiLDwy62CO15RjHEKK0s+IXMD4/bAHBRXsS8RGI
         2W80a6ftYKdrwXVt0acKVu9CL4I0k42KaJBz0lh0WWon2Z9Ty5KOjxjHCThG8w3IQgun
         7aHNcZmQsk6uHZ9zk6TpKEknyXc4twezFD90eeznNyeJQHVZzHcL+WSV5l7eIdeOczfv
         Y9P+xdjPkri242OzE6Ta/TG7fKauvCeprZC+4WtRYm3gHEF1lTDN3X8tSXiUGOq6mi5U
         QGSQ==
X-Gm-Message-State: APjAAAU0YBom6vDn+SsGeIgpjOP/jQAgqjm5mh/6JIMw2pS+CLpUmd2x
	L6Ulw/oqVAY1WAU7o55wV0G7T+6EAR5TLzNFSegqWMzYsiMyOf0kb+avd7cFSl3MkCFkkKeILSf
	ML2XgzTSmd4k=
X-Received: by 2002:aed:2a3d:: with SMTP id c58mr2413024qtd.263.1567783392782;
        Fri, 06 Sep 2019 08:23:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysRIOzKDov+VLJzuU+1EVJ6lS9gwz44EHckhRXGPrzep783X6xQjMVtNeoDnVh5QAs4+gXfA==
X-Received: by 2002:aed:2a3d:: with SMTP id c58mr2412982qtd.263.1567783392541;
        Fri, 06 Sep 2019 08:23:12 -0700 (PDT)
Received: from redhat.com (bzq-79-176-40-226.red.bezeqint.net. [79.176.40.226])
        by smtp.gmail.com with ESMTPSA id o67sm788480qkf.8.2019.09.06.08.23.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Sep 2019 08:23:11 -0700 (PDT)
Date: Fri, 6 Sep 2019 11:23:03 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org,
	osalvador@suse.de, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v8 0/7] mm / virtio: Provide support for unused page
 reporting
Message-ID: <20190906112155-mutt-send-email-mst@kernel.org>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 07:53:21AM -0700, Alexander Duyck wrote:
> This series provides an asynchronous means of reporting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allows
> for what I am referring to as unused page reporting
> 
> The functionality for this is fairly simple. When enabled it will allocate
> statistics to track the number of reported pages in a given free area.
> When the number of free pages exceeds this value plus a high water value,
> currently 32, it will begin performing page reporting which consists of
> pulling pages off of free list and placing them into a scatter list. The
> scatterlist is then given to the page reporting device and it will perform
> the required action to make the pages "reported", in the case of
> virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> and as such they are forced out of the guest. After this they are placed
> back on the free list, and an additional bit is added if they are not
> merged indicating that they are a reported buddy page instead of a
> standard buddy page. The cycle then repeats with additional non-reported
> pages being pulled until the free areas all consist of reported pages.
> 
> I am leaving a number of things hard-coded such as limiting the lowest
> order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> determine what the limit is on how many pages it wants to allocate to
> process the hints. The upper limit for this is based on the size of the
> queue used to store the scattergather list.

I queued this  so this gets tested on linux-next but the mm core changes
need acks from appropriate people.

> My primary testing has just been to verify the memory is being freed after
> allocation by running memhog 40g on a 40g guest and watching the total
> free memory via /proc/meminfo on the host. With this I have verified most
> of the memory is freed after each iteration. As far as performance I have
> been mainly focusing on the will-it-scale/page_fault1 test running with
> 16 vcpus. I have modified it to use Transparent Huge Pages. With this I
> see almost no difference, -0.08%, with the patches applied and the feature
> disabled. I see a regression of -0.86% with the feature enabled, but the
> madvise disabled in the hypervisor due to a device being assigned. With
> the feature fully enabled I see a regression of -3.27% versus the baseline
> without these patches applied. In my testing I found that most of the
> overhead was due to the page zeroing that comes as a result of the pages
> having to be faulted back into the guest.
> 
> One side effect of these patches is that the guest becomes much more
> resilient in terms of NUMA locality. With the pages being freed and then
> reallocated when used it allows for the pages to be much closer to the
> active thread, and as a result there can be situations where this patch
> set will out-perform the stock kernel when the guest memory is not local
> to the guest vCPUs. To avoid that in my testing I set the affinity of all
> the vCPUs and QEMU instance to the same node.
> 
> Changes from the RFC:
> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> Moved aeration requested flag out of aerator and into zone->flags.
> Moved boundary out of free_area and into local variables for aeration.
> Moved aeration cycle out of interrupt and into workqueue.
> Left nr_free as total pages instead of splitting it between raw and aerated.
> Combined size and physical address values in virtio ring into one 64b value.
> 
> Changes from v1:
> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> Dropped "waste page treatment" in favor of "page hinting"
> Renamed files and functions from "aeration" to "page_hinting"
> Moved from page->lru list to scatterlist
> Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sync
> Virtio now uses scatterlist directly instead of intermediate array
> Moved stats out of free_area, now in separate area and pointed to from zone
> Merged patch 5 into patch 4 to improve review-ability
> Updated various code comments throughout
> 
> Changes from v2:
> https://lore.kernel.org/lkml/20190724165158.6685.87228.stgit@localhost.localdomain/
> Dropped "page hinting" in favor of "page reporting"
> Renamed files from "hinting" to "reporting"
> Replaced "Hinted" page type with "Reported" page flag
> Added support for page poisoning while hinting is active
> Add QEMU patch that implements PAGE_POISON feature
> 
> Changes from v3:
> https://lore.kernel.org/lkml/20190801222158.22190.96964.stgit@localhost.localdomain/
> Added mutex lock around page reporting startup and shutdown
> Fixed reference to "page aeration" in patch 2
> Split page reporting function bit out into separate QEMU patch
> Limited capacity of scatterlist to vq size - 1 instead of vq size
> Added exception handling for case of virtio descriptor allocation failure
> 
> Changes from v4:
> https://lore.kernel.org/lkml/20190807224037.6891.53512.stgit@localhost.localdomain/
> Replaced spin_(un)lock with spin_(un)lock_irq in page_reporting_cycle()
> Dropped if/continue for ternary operator in page_reporting_process()
> Added checks for isolate and cma types to for_each_reporting_migratetype_order
> Added virtio-dev, Michal Hocko, and Oscar Salvador to to:/cc:
> Rebased on latest linux-next and QEMU git trees
> 
> Changes from v5:
> https://lore.kernel.org/lkml/20190812213158.22097.30576.stgit@localhost.localdomain/
> Replaced spin_(un)lock with spin_(un)lock_irq in page_reporting_startup()
> Updated shuffle code to use "shuffle_pick_tail" and updated patch description
> Dropped storage of order and migratettype while page is being reported
> Used get_pfnblock_migratetype to determine migratetype of page
> Renamed put_reported_page to free_reported_page, added order as argument
> Dropped check for CMA type as I believe we should be reporting those
> Added code to allow moving of reported pages into and out of isolation
> Defined page reporting order as minimum of Huge Page size vs MAX_ORDER - 1
> Cleaned up use of static branch usage for page_reporting_notify_enabled
> 
> Changes from v6:
> https://lore.kernel.org/lkml/20190821145806.20926.22448.stgit@localhost.localdomain/
> Rebased on linux-next for 20190903
> Added jump label to __page_reporting_request so we release RCU read lock
> Removed "- 1" from capacity limit based on virtio ring
> Added code to verify capacity is non-zero or return error on startup
> 
> Changes from v7:
> https://lore.kernel.org/lkml/20190904150920.13848.32271.stgit@localhost.localdomain/
> Updated poison fixes to clear flag if "nosanity" is enabled in kernel config
> Split shuffle per-cpu optimization into seperate patch
> Moved check for !phdev->capacity into reporting patch where it belongs
> Added Reviewed-by tags received for v7
> 
> ---
> 
> Alexander Duyck (7):
>       mm: Add per-cpu logic to page shuffling
>       mm: Adjust shuffle code to allow for future coalescing
>       mm: Move set/get_pcppage_migratetype to mmzone.h
>       mm: Use zone and order instead of free area in free_list manipulators
>       mm: Introduce Reported pages
>       virtio-balloon: Pull page poisoning config out of free page hinting
>       virtio-balloon: Add support for providing unused page reports to host
> 
> 
>  drivers/virtio/Kconfig              |    1 
>  drivers/virtio/virtio_balloon.c     |   87 ++++++++-
>  include/linux/mmzone.h              |  124 ++++++++-----
>  include/linux/page-flags.h          |   11 +
>  include/linux/page_reporting.h      |  177 ++++++++++++++++++
>  include/uapi/linux/virtio_balloon.h |    1 
>  mm/Kconfig                          |    5 +
>  mm/Makefile                         |    1 
>  mm/internal.h                       |   18 ++
>  mm/memory_hotplug.c                 |    1 
>  mm/page_alloc.c                     |  216 ++++++++++++++++------
>  mm/page_reporting.c                 |  340 +++++++++++++++++++++++++++++++++++
>  mm/shuffle.c                        |   40 ++--
>  mm/shuffle.h                        |   12 +
>  14 files changed, 902 insertions(+), 132 deletions(-)
>  create mode 100644 include/linux/page_reporting.h
>  create mode 100644 mm/page_reporting.c
> 
> --


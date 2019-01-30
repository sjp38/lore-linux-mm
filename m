Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B457C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6190420989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6190420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAECF8E0002; Wed, 30 Jan 2019 00:14:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5D1B8E0001; Wed, 30 Jan 2019 00:14:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFEA68E0002; Wed, 30 Jan 2019 00:14:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69BCD8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:14:50 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id v72so15535760pgb.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:14:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=AyLayKOp9xvWayn7qoGWXo3YM+8PLhs3t2dPFMaTvm8=;
        b=BPkItg8Zm/1uTJokQbcITOIa9/rTH4oFy7dFbWUYKbtfdXqr6yUsSzcjiSPDB9Btbv
         7ZjrQAjiY1AEJ6lGH1HzYMdM3p7dIeQxuMcpYrR5E5k9ywlnJe68TX4tBbDSTk+bbmsC
         cKSGU9Qfx3y0MZK0uodY6N9mU2k51udPFZ9MeXAIOGFe8vdoWAoT5STml0IgF+R9TiH3
         i+2LxnFFeD2bE+0wJG087Xo0/lbfY2xnDsopx3CGUB3Cxl0bxFW1Gwn0iRBv8mc1Bnfn
         yDD9V+d5v8Nz0r6DwuRId++EwG/TdcEstS9CIcCcZtv9JoGPLS6X6vPSVX848QtC4B/0
         7N+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukegP+GIDzeUUNuVgvxUGHqXvqOFk38y6/dk1MH3vZs7DSdQQtft
	4/GqC9z7mKrPPhVvN5raMF9D1YBtBVYK4vcdH2eVoQfAraOp1aQTnOGQAgPc9cWVT9EBJjQS+kp
	AL1UC48T29NOaaf1uvoYYgTiWzqKfsnosbldMAxbD7LJ8x4lodMmK3ZGwkIGf0432pQ==
X-Received: by 2002:a62:3006:: with SMTP id w6mr29387081pfw.258.1548825290036;
        Tue, 29 Jan 2019 21:14:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4URvvModgCDBYjn3FW6rtmnoMkmeFclRn+ZgUhaARZEFu1tBJQB+y0rtVfRShe1fCtQ38N
X-Received: by 2002:a62:3006:: with SMTP id w6mr29387043pfw.258.1548825288914;
        Tue, 29 Jan 2019 21:14:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548825288; cv=none;
        d=google.com; s=arc-20160816;
        b=jTdOkahsr41nRqo8w5UvCLSNcZYYkrNywwVeFJshVz1Owb8PTXyfLVKCgvzZPUbPHM
         1tit05MBQZUUdUKy8ucbQNahAwolLZ1XlJRSULM+VL1IZxY5Pyp+ugTVwg5Z8rUw1hxx
         zQ2GFlHbuN7ZwBkG3+3KppqeQcn+AjEcV2kO9QTQaWzTG4C8XEOF7Ipo7wPv/wt9yUqR
         ZI65FKnSKdou9Gkp5ctpBpBIwaHjhWHwAVKh/Xy6jc53zQSG9tINFrRU8nwfzQB02I0I
         vC6TR4TTAiTO6qj853UGlr1j6LG5iZfBsNrw3DSwq5dwlf3lCNHBrOIOaOeisVSpVusV
         Mrqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=AyLayKOp9xvWayn7qoGWXo3YM+8PLhs3t2dPFMaTvm8=;
        b=OpmfLnMIP1g4AjTPiYVk8wBCUC4l2R1qxIjm77lSPny26HIm7tUc2lcFunFFXC/JKx
         +VkiaGkKtb6jQOQQLQRT0FnnYaLXbTzPK2IcyWlspwE8dIl1DX1PUcdLjXgz0BiSArm9
         7toADGLgaxAq2KY6LU+pngokhaCVWlW0+12yvInO6UyeF8f5Zc6Z3RI4cXX1xPnuRFDm
         196XaaBZ89diPjHrDhuyF3uG+tjJkEBsX0pW5WyDPOcITHew383dGug98wV6nUa6pcn+
         gjJyB7Eb54dcKnQuuNb81gCbrp0EREgGRvVS6B8z5QiXOu2qvMK+BnbIfwHElDbL62e2
         WgVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y6si516606pll.384.2019.01.29.21.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 21:14:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 21:14:48 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,539,1539673200"; 
   d="scan'208";a="316032024"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005.fm.intel.com with ESMTP; 29 Jan 2019 21:14:47 -0800
Subject: [PATCH v9 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 29 Jan 2019 21:02:10 -0800
Message-ID: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v8 [1]:
* Rework shuffle call sites from 3 locations to 2, i.e. one for the
  initial memory online path, and one for the hotplug memory online path.
  This simplification results in an incremental diffstat of "7 files
  changed, 31 insertions(+), 82 deletions(-)". The consolidation of the
  initial shuffle in page_alloc_init_late() leads to a beneficial increase
  in the number of shuffles performed in a qemu-VM test. (Michal)

* Drop the CONFIG_SHUFFLE_PAGE_ORDER configuration option. If it turns out
  that there is a use case to make the shuffle-order dynamic that can be
  addressed in a follow on update, but no such case is known at present.
  (Michal)

* Replace lkml.org links with lkml.kernel.org, where possible.
  Unfortunately lkml.kernel.org failed to capture Mel's feedback, so the
  lkml.org link remains for that one. (Michal)

* Fix definition of pfn_present() in the !sparsemem case. (Michal)

* Collect Michal's ack on patch2, and open code rmv_page_order() in its
  only caller.

[1]: https://lkml.kernel.org/r/154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com

---

Hi Andrew,

As you can see the series is improved thanks to Michal's review. Please
await his ack, but I believe this version addresses all pending
feedback.

Still based on v5.0-rc1 for my tests, but it applies and builds cleanly
to current linux-next.

---

Quote Patch 1:

Randomization of the page allocator improves the average utilization of
a direct-mapped memory-side-cache. Memory side caching is a platform
capability that Linux has been previously exposed to in HPC
(high-performance computing) environments on specialty platforms. In
that instance it was a smaller pool of high-bandwidth-memory relative to
higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
be found on general purpose server platforms where DRAM is a cache in
front of higher latency persistent memory [2].

Robert offered an explanation of the state of the art of Linux
interactions with memory-side-caches [3], and I copy it here:

    It's been a problem in the HPC space:
    http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/

    A kernel module called zonesort is available to try to help:
    https://software.intel.com/en-us/articles/xeon-phi-software

    and this abandoned patch series proposed that for the kernel:
    https://lkml.kernel.org/r/20170823100205.17311-1-lukasz.daniluk@intel.com

    Dan's patch series doesn't attempt to ensure buffers won't conflict, but
    also reduces the chance that the buffers will. This will make performance
    more consistent, albeit slower than "optimal" (which is near impossible
    to attain in a general-purpose kernel).  That's better than forcing
    users to deploy remedies like:
        "To eliminate this gradual degradation, we have added a Stream
         measurement to the Node Health Check that follows each job;
         nodes are rebooted whenever their measured memory bandwidth
         falls below 300 GB/s."

A replacement for zonesort was merged upstream in commit cc9aec03e58f
"x86/numa_emulation: Introduce uniform split capability". With this
numa_emulation capability, memory can be split into cache sized
("near-memory" sized) numa nodes. A bind operation to such a node, and
disabling workloads on other nodes, enables full cache performance.
However, once the workload exceeds the cache size then cache conflicts
are unavoidable. While HPC environments might be able to tolerate
time-scheduling of cache sized workloads, for general purpose server
platforms, the oversubscribed cache case will be the common case.

The worst case scenario is that a server system owner benchmarks a
workload at boot with an un-contended cache only to see that performance
degrade over time, even below the average cache performance due to
excessive conflicts. Randomization clips the peaks and fills in the
valleys of cache utilization to yield steady average performance.

See patch 1 for more details.

[2]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
[3]: https://lkml.kernel.org/r/AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM

---

Dan Williams (3):
      mm: Shuffle initial free memory to improve memory-side-cache utilization
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 ++++
 include/linux/mm.h       |    3 -
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   62 ++++++++++++++
 include/linux/shuffle.h  |   57 +++++++++++++
 init/Kconfig             |   23 +++++
 mm/Makefile              |    7 +-
 mm/compaction.c          |    4 -
 mm/memblock.c            |    1 
 mm/memory_hotplug.c      |    3 +
 mm/page_alloc.c          |   85 +++++++++----------
 mm/shuffle.c             |  204 ++++++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 419 insertions(+), 50 deletions(-)
 create mode 100644 include/linux/shuffle.h
 create mode 100644 mm/shuffle.c


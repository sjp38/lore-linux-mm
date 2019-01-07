Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C217EC43612
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 23:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64A6D2070B
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 23:33:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64A6D2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92568E0042; Mon,  7 Jan 2019 18:33:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42968E0038; Mon,  7 Jan 2019 18:33:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5C558E0042; Mon,  7 Jan 2019 18:33:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62E138E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:33:44 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so1316199pfk.12
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:33:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=M3Y/W/xD9xxYeENhuSYkEXkICApRXvHEUJCKCvRnYH4=;
        b=mf8g2SpOGORVat6fEJjYafrFpS5bwwGTIUIBfsG5M9omxAsNJhyEiuIIO94UKkx3zx
         IZ4dNvJYUvNQ2Oh3vTFxo/cpGAZP5K9YWYUXjxtBxgvJZB72Yq+vEDAJI2cS/RdVKv23
         Sihh40ydrI0NjGPLY3F4jAGDeIj4hS6d0nkLrIvfw2oSRTt7fmm+UXSb/+MOHB+PdTfF
         MfujVRcj97TZNxAF0a8sksF+OuWbXrPzTegA3PwSkwN0MiEqeRplsczTikVk9LydiDLy
         vdvLSDvOpm7iqCfZZ+VBjtkY36G3BJDNeode1toenC6CkBfhZw+q4M+stxRUbQEGAFYh
         IIFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke0N/X80orfiElqfaLx2hh0BW3pc+xlHe6Q5VJ8W+RtowDoBVJm
	6brL68j3QihOsDU0IC6sCGKwvRAtJJes8QD0NOKApv/VZbDuD0Zl19H3Tqu/qVzRXRWUOfrIVIJ
	ZzZ9TsEwYfUgrxWsradJz3IQpWcx0hNUT9HZgEq/NFshsyEvnWe50vyDM29KdI5WjBQ==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr63984327plp.34.1546904023929;
        Mon, 07 Jan 2019 15:33:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5tZXlGy4Wo28xFWIZDKeW9h3HojuzYoLXu4kf+jMFOKxojFYI2KUC0RCShtJpyiHCPdNvV
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr63984280plp.34.1546904022750;
        Mon, 07 Jan 2019 15:33:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546904022; cv=none;
        d=google.com; s=arc-20160816;
        b=cWojl/iEizVZujGsk2o6Eh/uxNRwzisG95o4uzObXDFqPG41UzgRmRv9lO3z9hyho2
         cFoeA15du6aSbqeVc/cMiUgyLzp1YffXsKX0UbRIqmNEExo1EY2FJZ5DNoGVvBIFvltb
         SqWVVKULNK6rmxAYQB1SUxQILT+lw3wy36CgWe7tLaY/ktRJNUcphgTv2dnu5fWQzkiS
         bIma7ksrOBjD+DzSQABiQZpXoWSnguDK8hI2wMyyoHxlwr3jM4txLWlRgn+ltli+CLCJ
         BcLrRSPng+w2dQdk+Wx6TFGiarZrpGOWByP8aK971mAUSy2FKXUk0y9ZKLR3K0TnMkee
         uBAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=M3Y/W/xD9xxYeENhuSYkEXkICApRXvHEUJCKCvRnYH4=;
        b=G3BJBnx9qkJqR3D4z8vBWE92Eri/t7l/EUynwKxtBW+3VirU33DTVQV9oQAjW98LS7
         TPcqUol4LPu68x4OuJ1TCdPqqQTfYGtwYWbzzuwA+PlQ1qNQOKpzXPXA/ibWG3S0a92h
         SC5NgCtZL5zzvY5V+yLALbwFVrc1B1HOilh32BsKf7IMreJQ8bELV4J/D7OpzdqACxq6
         Sx7Cgo97GGW/r3Jo8Oq5zzYf4AniACUcvy8/0/v+tmYyRabKOl86nSRYeAN37TJs7wJp
         Q/Q6vqToTw2ARaCqYxUc2qbiHInGi3Qw+rF7giRNluRA2+W5JE8gaiezlFiA42ixA7gm
         O1ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e6si10479033pgp.504.2019.01.07.15.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:33:42 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jan 2019 15:33:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,451,1539673200"; 
   d="scan'208";a="124068789"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by FMSMGA003.fm.intel.com with ESMTP; 07 Jan 2019 15:33:41 -0800
Subject: [PATCH v7 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>,
 mhocko@suse.com, keith.busch@intel.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mgorman@suse.de
Date: Mon, 07 Jan 2019 15:21:04 -0800
Message-ID:
 <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107232104.9Z0k1UtzhgQtzRsgHbPjlPnzP0nHVMD8yfYA1OeuYF8@z>

Changes since v6 [1]:
* Simplify the review, drop the autodetect patches from the series. That
  work simply results in a single call to page_alloc_shuffle(SHUFFLE_ENABLE)
  injected at the right location during ACPI NUMA initialization / parsing
  of the HMAT (Heterogeneous Memory Attributes Table). That is purely a
  follow-on consideration once the base shuffle implementation and
  definition of page_alloc_shuffle() is accepted. The end result for this
  series is that the command line parameter "page_alloc.shuffle" is
  required to enable the randomization.

* Fix declaration of page_alloc_shuffle() in the
  CONFIG_SHUFFLE_PAGE_ALLOCATOR=n case. (0day)

* Rebased on v5.0-rc1

[1]: https://lkml.org/lkml/2018/12/17/1116

---

Hi Andrew, please consider this series for -mm only after Michal and Mel
have had a chance to review and have their concerns addressed.

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
    https://lkml.org/lkml/2017/8/23/195

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
[3]: https://lkml.org/lkml/2018/9/22/54

---

Dan Williams (3):
      mm: Shuffle initial free memory to improve memory-side-cache utilization
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 +++
 include/linux/mm.h       |    3 -
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   65 +++++++++++++
 include/linux/shuffle.h  |   60 ++++++++++++
 init/Kconfig             |   36 +++++++
 mm/Makefile              |    7 +
 mm/compaction.c          |    4 -
 mm/memblock.c            |   10 ++
 mm/memory_hotplug.c      |    3 +
 mm/page_alloc.c          |   82 ++++++++--------
 mm/shuffle.c             |  231 ++++++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 471 insertions(+), 50 deletions(-)
 create mode 100644 include/linux/shuffle.h
 create mode 100644 mm/shuffle.c


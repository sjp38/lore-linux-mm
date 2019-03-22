Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A8AEC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14F9321900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14F9321900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A96D46B0003; Fri, 22 Mar 2019 13:10:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A43F16B0006; Fri, 22 Mar 2019 13:10:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F33E6B0007; Fri, 22 Mar 2019 13:10:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC006B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:10:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e5so2879707pfi.23
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:10:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=wDOla95F+7PUiMB0SBg+Qt/3Z1LKDaYt8CSBbTZcfTU=;
        b=GEmZwAdeFHlnbZHO2L3uMOEXUR7EWlm+5PVIE+0jytAvqSlOTjCX/j47yq4QgDVQHZ
         3ZbSH12RN375LYHlwcYtkpr+1T0SX09w75jdbtd1oc679IFXDIHMnySy+pPZrJ2i6v3w
         cjALQHDc4XVvJkzyTosvSbMirk32nIj/cjq+OGGYpn/1X2BZ/opCdE2vG9VJeb470Iyc
         RN8l0n/EELjjuvvWXyn94/c/IHq5YAWshmubV33y8Gy+VUo2P8oxe/XUpXZvtFuG/8gB
         spJgVyVf+rmXsSX3WEhJ3GWy8PyIMIwTzCv/i5CrYAET1HJ0JUEJERfvNnJMg+Wyre58
         04kg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWDBUCN/SNyrT1BU1lQHhro2J3qimbjBSASriZwAnxnL/7a/PPf
	U10SOxh/8c1OB19ryK//DWaskyWOI2OnUFMJopcEjb84kNb1Wzp5jibshv7LMLb47nNrBpbzsOk
	/YHdKNt5WV8l3qEDDthENgUAYXIjNPr/yO6QiK8w4Bp+vxKNxZJhQ25gWhL4ZgXibpw==
X-Received: by 2002:a63:561f:: with SMTP id k31mr10105312pgb.319.1553274634925;
        Fri, 22 Mar 2019 10:10:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxx//hF9rn8TUaThCg3lWcwX/1Ly4xBpXfojLX6DFV2N/g4SwWsYM9iQSVjk50I4HpuZMFa
X-Received: by 2002:a63:561f:: with SMTP id k31mr10105234pgb.319.1553274633956;
        Fri, 22 Mar 2019 10:10:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274633; cv=none;
        d=google.com; s=arc-20160816;
        b=sBz6k3YSoe2SwBlzcizFny8jeO2Y1D77oPXcI2/Uln0CHw5Ug/8E+U+EnubmQaOx8t
         fhZU85mE1RwupY70NfHv0mNGVtcOO38vKPBg0Q+8vg2IOo6H0Nqh1FlOBOhXd6MPmCTD
         RWEcCMqTPmmf9VxrnvGNKy/aCf2uaGJxOWbtY99mp+yFCgiijryNeiQb0MQ/4R79aoIP
         NqHvHhl3XmoGF730O1xa1moQuxeUox1LekbpNh3vnzkkUjoKpkJFKAxNEddSdDg18mvg
         rMqC9wLNusJ/weHVQ4hkM3z4upnr4UUHpeWrz7hEvs1cm/GUJuxYPcA0pPmDAGF8xS/x
         LS+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=wDOla95F+7PUiMB0SBg+Qt/3Z1LKDaYt8CSBbTZcfTU=;
        b=RVG+YkisFscLLSoxLFOvYwyTFTZsFdRyxKpA7PdKXIIjaZcLh+3TMxXA0RviJDdzi5
         CpSCjF9R4+unr3MiW9QimsvhNG6FlOn+2WXE6t0rBRC4AYEJOlWUh4W//hNvXu1Gar5N
         8p6nGc8Kq5ZcoD788ITdH8dNqPAAcDQxKQjH32xyutv+4Dm9P1LYSD7/mfB5y85gnno3
         KRLbaKCxgS5ThqtPeuDxp22pvuOdCaUt6HAoybzLTQ38vPSOcVqoJWJj+n5bSQdLb2Kf
         DC/QW6Str/2iMjlJETQEBQB+3N+m3Jd6wwB9ThOqnMMJAaOwSIJXZIvQ9MQ0qU9Xz0BY
         eMVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s10si6943112pgp.564.2019.03.22.10.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:10:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:10:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="154240203"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga002.fm.intel.com with ESMTP; 22 Mar 2019 10:10:33 -0700
Subject: [PATCH v5 00/10] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:57:54 -0700
Message-ID: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v4 [1]:
- Given v4 was from March of 2017 the bulk of the changes result from
  rebasing the patch set from a v4.11-rc2 baseline to v5.1-rc1.

- A unit test is added to ndctl to exercise the creation and dax
  mounting of multiple independent namespaces in a single 128M section.

[1]: https://lwn.net/Articles/717383/

---

Quote patch7:

"The libnvdimm sub-system has suffered a series of hacks and broken
 workarounds for the memory-hotplug implementation's awkward
 section-aligned (128MB) granularity. For example the following backtrace
 is emitted when attempting arch_add_memory() with physical address
 ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
 within a given section:
 
  WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
  devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
  [..]
  Call Trace:
    dump_stack+0x86/0xc3
    __warn+0xcb/0xf0
    warn_slowpath_fmt+0x5f/0x80
    devm_memremap_pages+0x3b5/0x4c0
    __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
    pmem_attach_disk+0x19a/0x440 [nd_pmem]
 
 Recently it was discovered that the problem goes beyond RAM vs PMEM
 collisions as some platform produce PMEM vs PMEM collisions within a
 given section. The libnvdimm workaround for that case revealed that the
 libnvdimm section-alignment-padding implementation has been broken for a
 long while. A fix for that long-standing breakage introduces as many
 problems as it solves as it would require a backward-incompatible change
 to the namespace metadata interpretation. Instead of that dubious route
 [2], address the root problem in the memory-hotplug implementation."

The approach is taken is to observe that each section already maintains
an array of 'unsigned long' values to hold the pageblock_flags. A single
additional 'unsigned long' is added to house a 'sub-section active'
bitmask. Each bit tracks the mapped state of one sub-section's worth of
capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.

The implication of allowing sections to be piecemeal mapped/unmapped is
that the valid_section() helper is no longer authoritative to determine
if a section is fully mapped. Instead pfn_valid() is updated to consult
the section-active bitmask. Given that typical memory hotplug still has
deep "section" dependencies the sub-section capability is limited to
'want_memblock=false' invocations of arch_add_memory(), effectively only
devm_memremap_pages() users for now.

With this in place the hacks in the libnvdimm sub-system can be
dropped, and other devm_memremap_pages() users need no longer be
constrained to 128MB mapping granularity.

[2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com

---

Dan Williams (10):
      mm/sparsemem: Introduce struct mem_section_usage
      mm/sparsemem: Introduce common definitions for the size and mask of a section
      mm/sparsemem: Add helpers track active portions of a section at boot
      mm/hotplug: Prepare shrink_{zone,pgdat}_span for sub-section removal
      mm/sparsemem: Convert kmalloc_section_memmap() to populate_section_memmap()
      mm/sparsemem: Prepare for sub-section ranges
      mm/sparsemem: Support sub-section hotplug
      mm/devm_memremap_pages: Enable sub-section remap
      libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
      libnvdimm/pfn: Stop padding pmem namespaces to section alignment


 arch/x86/mm/init_64.c          |   15 +-
 drivers/nvdimm/dax_devs.c      |    2 
 drivers/nvdimm/pfn.h           |   12 -
 drivers/nvdimm/pfn_devs.c      |   93 +++-------
 include/linux/memory_hotplug.h |    7 -
 include/linux/mm.h             |    4 
 include/linux/mmzone.h         |   60 ++++++
 kernel/memremap.c              |   57 ++----
 mm/hmm.c                       |    2 
 mm/memory_hotplug.c            |  119 +++++++-----
 mm/page_alloc.c                |    6 -
 mm/sparse-vmemmap.c            |   21 +-
 mm/sparse.c                    |  382 ++++++++++++++++++++++++++++------------
 13 files changed, 476 insertions(+), 304 deletions(-)


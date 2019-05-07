Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 873BFC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2439620675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2439620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931DB6B0005; Tue,  7 May 2019 20:09:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3AB6B0006; Tue,  7 May 2019 20:09:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F9B96B0008; Tue,  7 May 2019 20:09:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4940A6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:09:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d21so11359024pfr.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:09:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=0DJEY9TTC43pyuA4jJrV6wtcIkHrbLDtdxBNa4IXge0=;
        b=cVZgZN/Ad2YAHAA1Gvouusr339dmXsdEep2Z/cOkibRCaD8c3JY7804RP7Li66UVqh
         AEwrH0sQf74A1QZ3oaF2WmbvaIJ979Uve/2B6IBDeJfARoHGWtN11S7dHDKa6ELm/s+2
         475OXSQkBTez3pqTjp/qcxOg5adpB2jXpDHlTz5clgpYg8k0NG3LQTl6+LRWOknSYudU
         HaegwUVNT3S4jClrOSh305HoDkm28kmD1webNnKHy76XEnJ0NknarFGISfdljfZiOmHQ
         d34f5VT9kj7ZwVheaCQaJhRif0E/HOWhpXu7Qf/Hh1WKkqG1tKtrvb5a/jluRYNgupoK
         IpnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVgtZdMkVOBQiIgj+XBu9ko2Ub+RldN8dRjKEnSaA3pVHQJMECi
	AQDF4YcCTDA1+cioSqx6UVURZF7MLs+NONL55bmNKY1r9Y9Q1Yr01cxWUF/5fflzCdL/m2BoArz
	gYxtyZIA3W4v4RVpzWCN/dsWwX5JMGOfkEMqv+YzBpzDkjUfnBTBMxCKfokQ025TVUg==
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr43731091pfo.85.1557274188937;
        Tue, 07 May 2019 17:09:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqyPd/WwEfS4wqglexlmvuXgNr2yjcur5R1Xn7iQPePFprtcR3Mixf6LmkS9f2noWXTS9x
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr43730976pfo.85.1557274187407;
        Tue, 07 May 2019 17:09:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274187; cv=none;
        d=google.com; s=arc-20160816;
        b=EVprrRoQv81OrFFxwI+9c4oyjg+3nNksUR2WxPh7s7v9xBmWnDw9E1+Q0mmWZLbVR4
         PqNqQid7TL8d8n4mjwkmiL7LLLttpPbR3jMRhKHGenz82s3zfxG+Ej++1knFa/PKC6rr
         BP7Lgjfy4V5lKYRY7YHVQSed9rqKtfkR6EYa2ktJuXUmQ/dq2JiIGGk5/abplRrPKkgz
         LlqMElLI65cn9EY/mF7twH+8HmiSOzUuwz2QvlMXaP38c9ost5fa/7H1+Xlwk/FRy5p6
         F+QjixpDa+u4ybrjugvCcMfen6plkfQyywVNf98SGY3AJv2Taw54kSQtYEgSsqz/2mwe
         gx+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=0DJEY9TTC43pyuA4jJrV6wtcIkHrbLDtdxBNa4IXge0=;
        b=ZlmDN9jny0uqfrQwOJdWqiASBjWrV/1Rn9VyI32PFQXJNK75iAEW0pYI3Admm9HkEO
         UHJwxwvM65YhdaZdH8WIrPUxc+uCwFEyHTk+x9tlpd1dgYN76Xitg0tlXDPbkGiR4drO
         6c/W9gYvrTzWaQrlI3guFqnq7CESzlFTVrgHXwg7xblOHm+qckqanzhswzLm5oTvwwnE
         bit9TO/eg4yXOA+rAzg3N06iszF+cu/Ly0n5nIvLo7GsQFGwZoSQJdNPaGx3TpMny84+
         2BU4OUCcqRfcu3bEnvRHzNdmvHCjz7iIR2b+MHP//8CtiOAlVyVYJqZU+KLXuiyOD1am
         yHUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 144si11128746pgh.524.2019.05.07.17.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:09:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:09:46 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga004.fm.intel.com with ESMTP; 07 May 2019 17:09:46 -0700
Subject: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Ira Weiny <ira.weiny@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:55:59 -0700
Message-ID: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v1 [1]:
- Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)

- Refresh the p2pdma patch headers to match the format of other p2pdma
  patches (Bjorn)

- Collect Ira's reviewed-by

[1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/

---

Logan audited the devm_memremap_pages() shutdown path and noticed that
it was possible to proceed to arch_remove_memory() before all
potential page references have been reaped.

Introduce a new ->cleanup() callback to do the work of waiting for any
straggling page references and then perform the percpu_ref_exit() in
devm_memremap_pages_release() context.

For p2pdma this involves some deeper reworks to reference count
resources on a per-instance basis rather than a per pci-device basis. A
modified genalloc api is introduced to convey a driver-private pointer
through gen_pool_{alloc,free}() interfaces. Also, a
devm_memunmap_pages() api is introduced since p2pdma does not
auto-release resources on a setup failure.

The dax and pmem changes pass the nvdimm unit tests, and the p2pdma
changes should now pass testing with the pci_p2pdma_release() fix.
Jérôme, how does this look for HMM?

In general, I think these patches / fixes are suitable for v5.2-rc1 or
v5.2-rc2, and since they touch kernel/memremap.c, and other various
pieces of the core, they should go through the -mm tree. These patches
merge cleanly with the current state of -next, pass the nvdimm unit
tests, and are exposed to the 0day robot with no issues reported
(https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=libnvdimm-pending).

---

Dan Williams (6):
      drivers/base/devres: Introduce devm_release_action()
      mm/devm_memremap_pages: Introduce devm_memunmap_pages
      PCI/P2PDMA: Fix the gen_pool_add_virt() failure path
      lib/genalloc: Introduce chunk owners
      PCI/P2PDMA: Track pgmap references per resource, not globally
      mm/devm_memremap_pages: Fix final page put race


 drivers/base/devres.c             |   24 +++++++-
 drivers/dax/device.c              |   13 +---
 drivers/nvdimm/pmem.c             |   17 ++++-
 drivers/pci/p2pdma.c              |  115 +++++++++++++++++++++++--------------
 include/linux/device.h            |    1 
 include/linux/genalloc.h          |   55 ++++++++++++++++--
 include/linux/memremap.h          |    8 +++
 kernel/memremap.c                 |   23 ++++++-
 lib/genalloc.c                    |   51 ++++++++--------
 mm/hmm.c                          |   14 +----
 tools/testing/nvdimm/test/iomap.c |    2 +
 11 files changed, 217 insertions(+), 106 deletions(-)


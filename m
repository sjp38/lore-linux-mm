Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 610FDC282C6
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CBF6218D3
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CBF6218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD9358E00AD; Thu, 24 Jan 2019 18:21:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAE0A8E00AC; Thu, 24 Jan 2019 18:21:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C42C8E00AD; Thu, 24 Jan 2019 18:21:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58BA78E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:53 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so4955458plt.7
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:message-id;
        bh=QvZnb18fNlFv+urXniHrfn2rxJeV1WV6da2ymalnQuU=;
        b=Y5wI04WNnW7LznZHbLAnWtUotwB9il561BjPfeEJN0EII+wnHpLKxLEFoZXU4KVbWX
         w/+tQucgD08UZrf8pU/e1PmVJm2CQc97DxmAt3O0Xl4BPS4u6LEyB2b2sVjxJZd0v1vE
         j9+TdFV+Fwr5gU997lBfTP61k5MYXBnNQv4LzCVSO0IIdTIPNW67IO00TP48cWZdB9+H
         TeQKU5rVM4WzeMULOmLFn5zmdfzJ0tv7eawF6O8pGP0q7CCC9Pz1VXvPn4FQS+KQoEFs
         HG5IpFCWbIOhsg3R0iBcP5Lf0G1xsIKQbEamveftgOboE6PbIQUPsLMpOIScXktcBYdk
         61cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke+wvxUsP5N+3HMsdZMNjp/ouyLJhQyzOAdTZItJMMc4N1XLkdm
	IILp7P8TJx6cAv6PBWG++HAlSKA5nthEuqk1aT2DoqdZTNjKy1O28ByZaMg9/e8Iy+0F2bO/sHq
	ABTM7vQNMObk2tpHC2MK+7tYF7pAbqKVE9VgLSU2iSq4VkFO64+6BLiQiFnFAKOWwCw==
X-Received: by 2002:a63:ba4d:: with SMTP id l13mr7737052pgu.194.1548372112930;
        Thu, 24 Jan 2019 15:21:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7PCZuKyQrW+0AyD0RQHMYDmSVN59k37AGOGbvzycD3vdjj+l6c7te7r9w9msKJKv1RIFn5
X-Received: by 2002:a63:ba4d:: with SMTP id l13mr7736997pgu.194.1548372111544;
        Thu, 24 Jan 2019 15:21:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548372111; cv=none;
        d=google.com; s=arc-20160816;
        b=ISw+vgQZJ7uxTvpZT+tld2KjWSZ/8gC3K5IJ4XEC2ZTiydvc606te4xZlt23opFPWk
         dDnfeldfw+qrK0wv6RaGugVx+fnsIvt90TMtDWvwwCqZM5bfB34lEolwUUHdtoh/j/+q
         7cfVUnXk48eOKCu0OdWU1U2IYInCsMb1JemMmOx886j64L4128mQVfwajEMKx+EygVuE
         etoG+tC4x9Wfug93oJCn/x6eAYs3VzaPNXhKLWCPoYH94HqM9x1bgI3tXzzwNLdmHMNp
         g95lZ66Og9y0tT2j/7mrsglCO66fSxvO16Ss2R5W9hfHgVzsHnBs+Jn3tB8aVizyjxPY
         soCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:from:cc:to:subject;
        bh=QvZnb18fNlFv+urXniHrfn2rxJeV1WV6da2ymalnQuU=;
        b=0rh77DSiIjd5+TWFpimlTbmeid3VS4iADuDP4aMInQs31YIjhd6RR9B3iXRwldAdcI
         UD5sou+6IJ8VRuX6WqEtlE/48dC/K5VWjRzLTMdfTvY4RCMcQ2MFiX/hCPROC4RQO8s0
         lQll0r+U9QNdgKTx+nHTgqJ0q2hWiKAWMIcfix2ieZXkxdR/zdgkZJqj5I5b2FkT0lsm
         1K8Dq+eiuMv2+r9STl2Uo+XGYHeBrAHGqn1IRMnommjGxtHVrdSz1Tza3SUrsJFaAi1T
         JvYDwUH87HS3G/t3Svi2gqJDP5wC3QKdeOM0e4TgZENmS/M3NzCMlfoRafB96kCxp0Ps
         jFRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l81si23166521pfj.230.2019.01.24.15.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:51 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 15:21:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,518,1539673200"; 
   d="scan'208";a="128689433"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga002.jf.intel.com with ESMTP; 24 Jan 2019 15:21:50 -0800
Subject: [PATCH 0/5] [v4] Allow persistent memory to be used like normal RAM
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:41 -0800
Message-Id: <20190124231441.37A4A305@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190124231441.ySKeJZvgD_h_lxhe0puKYvGqJGsuXAz5UIy79we-qJA@z>

v3 spurred a bunch of really good discussion.  Thanks to everybody
that made comments and suggestions!

I would still love some Acks on this from the folks on cc, even if it
is on just the patch touching your area.

Note: these are based on commit d2f33c19644 in:

	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git libnvdimm-pending

Changes since v3:
 * Move HMM-related resource warning instead of removing it
 * Use __request_resource() directly instead of devm.
 * Create a separate DAX_PMEM Kconfig option, complete with help text
 * Update patch descriptions and cover letter to give a better
   overview of use-cases and hardware where this might be useful.

Changes since v2:
 * Updates to dev_dax_kmem_probe() in patch 5:
   * Reject probes for devices with bad NUMA nodes.  Keeps slow
     memory from being added to node 0.
   * Use raw request_mem_region()
   * Add comments about permanent reservation
   * use dev_*() instead of printk's
 * Add references to nvdimm documentation in descriptions
 * Remove unneeded GPL export
 * Add Kconfig prompt and help text

Changes since v1:
 * Now based on git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git
 * Use binding/unbinding from "dax bus" code
 * Move over to a "dax bus" driver from being an nvdimm driver

--

Persistent memory is cool.  But, currently, you have to rewrite
your applications to use it.  Wouldn't it be cool if you could
just have it show up in your system like normal RAM and get to
it like a slow blob of memory?  Well... have I got the patch
series for you!

== Background / Use Cases ==

Persistent Memory (aka Non-Volatile DIMMs / NVDIMMS) themselves
are described in detail in Documentation/nvdimm/nvdimm.txt.
However, this documentation focuses on actually using them as
storage.  This set is focused on using NVDIMMs as DRAM replacement.

This is intended for Intel-style NVDIMMs (aka. Intel Optane DC
persistent memory) NVDIMMs.  These DIMMs are physically persistent,
more akin to flash than traditional RAM.  They are also expected to
be more cost-effective than using RAM, which is why folks want this
set in the first place.

This set is not intended for RAM-based NVDIMMs.  Those are not
cost-effective vs. plain RAM, and this using them here would simply
be a waste.

But, why would you bother with this approach?  Intel itself [1]
has announced a hardware feature that does something very similar:
"Memory Mode" which turns DRAM into a cache in front of persistent
memory, which is then as a whole used as normal "RAM"?

Here are a few reasons:
1. The capacity of memory mode is the size of your persistent
   memory that you dedicate.  DRAM capacity is "lost" because it
   is used for cache.  With this, you get PMEM+DRAM capacity for
   memory.
2. DRAM acts as a cache with memory mode, and caches can lead to
   unpredictable latencies.  Since memory mode is all-or-nothing
   (either all your DRAM is used as cache or none is), your entire
   memory space is exposed to these unpredictable latencies.  This
   solution lets you guarantee DRAM latencies if you need them.
3. The new "tier" of memory is exposed to software.  That means
   that you can build tiered applications or infrastructure.  A
   cloud provider could sell cheaper VMs that use more PMEM and
   more expensive ones that use DRAM.  That's impossible with
   memory mode.

Don't take this as criticism of memory mode.  Memory mode is
awesome, and doesn't strictly require *any* software changes (we
have software changes proposed for optimizing it though).  It has
tons of other advantages over *this* approach.  Basically, we
believe that the approach in these patches is complementary to
memory mode and that both can live side-by-side in harmony.

== Patch Set Overview ==

This series adds a new "driver" to which pmem devices can be
attached.  Once attached, the memory "owned" by the device is
hot-added to the kernel and managed like any other memory.  On
systems with an HMAT (a new ACPI table), each socket (roughly)
will have a separate NUMA node for its persistent memory so
this newly-added memory can be selected by its unique NUMA
node.

== Testing Overview ==

Here's how I set up a system to test this thing:

1. Boot qemu with lots of memory: "-m 4096", for instance
2. Reserve 512MB of physical memory.  Reserving a spot a 2GB
   physical seems to work: memmap=512M!0x0000000080000000
   This will end up looking like a pmem device at boot.
3. When booted, convert fsdax device to "device dax":
	ndctl create-namespace -fe namespace0.0 -m dax
4. See patch 4 for instructions on binding the kmem driver
   to a device.
5. Now, online the new memory sections.  Perhaps:

grep ^MemTotal /proc/meminfo
for f in `grep -vl online /sys/devices/system/memory/*/state`; do
	echo $f: `cat $f`
	echo online_movable > $f
	grep ^MemTotal /proc/meminfo
done

1. https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/#gs.RKG7BeIu

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>


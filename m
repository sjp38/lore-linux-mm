Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80956C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 424842084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 424842084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2E3E8E0009; Mon, 25 Feb 2019 14:02:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDCBA8E0004; Mon, 25 Feb 2019 14:02:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA4D28E0009; Mon, 25 Feb 2019 14:02:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73E708E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:35 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id s22so7901090plq.7
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:message-id;
        bh=cCeoW4rpPMqfQkc2PWxX3Vlrr6DBBt4uyN0ZRen+aAQ=;
        b=X7ZwHt/pLln3BRr7hm7DTmN8oMBhb4LYPpVzxDjiwf9Ne3e2LPMeDUhtgNjFPLxWgm
         5YcfRLDVKrFe2S4JOe14SJ5osRGoH3R9QZSE3rtOE66kXNnPuDGx4yc++thykxYiQucZ
         5i2uaohBgA0eETARrTKcYI09dF+H3Ml8sFikng09foOMc4e/uQCzj8evNr10jYML2o1f
         0qEiZYV/YhPpslYw84IDFqQI/sNu5ndXWL627QbZY5QEyjWv3FLDyfadOje8hdTrqcAW
         NdCtBy4/5wriZ0CR5n5boRKxo3079wV3zTdljEvmfzhb1PPYV+qDmvdRJrjiNKmgEzTf
         TnqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY520ZXIq3jgBEdp4PispCpD6MXqEC78UccOmuqJ27Us8V/363P
	bYwK/5sXtdsUWkU0hca1ePUJFTgQFsxt/p02FrfWo8Qb1tK91CdiCCfW5nVx3+QR6IS3U1Ar9Ec
	J/eiXPjuZ2qJJ6RR0+q6Sq1u0R2bHbAP2s3L1jsl0iMKS7Y3OtWzx97gBeVx7g35rfQ==
X-Received: by 2002:a62:13da:: with SMTP id 87mr10330259pft.173.1551121355001;
        Mon, 25 Feb 2019 11:02:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJFhFXr+kem85IpOO6XcQPoqfUmf5Rb+eJeXJ4bOBKm2T7Wc5nJ9EsAZZHguIRVq/KFIli
X-Received: by 2002:a62:13da:: with SMTP id 87mr10330128pft.173.1551121353356;
        Mon, 25 Feb 2019 11:02:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121353; cv=none;
        d=google.com; s=arc-20160816;
        b=TAbY9HcgncumwOjLL1WJrXLW3Bk6CNnmvgPxd8f+fU2WKTwijOHfrUWhOA3MxwKXnf
         OnrFoKNLlp6OQo+0XXj6aiX89CLKay8zvjMLObHb9P3+J+cOpZXG/+wydIxHe6l9+mEQ
         SXU/e/1HYOfz+O9IjERZPyVGfGj6Luqd5xbLMegrQ9YNpcT3tdMxrfp26p6EMCK9UsnQ
         M1zTeqivNAvZPec/LDhadUo8lMrfG3vkzi31U4rdeRqtt1d7pfsBCi7nXrLvdymdK9S6
         QV7OMl2OlwWNkZhm5L8QKjK0T6tHlIhpqzVDsL/ykHei0p+AePoZhfWcx9941+hu1IO3
         1Dcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:from:cc:to:subject;
        bh=cCeoW4rpPMqfQkc2PWxX3Vlrr6DBBt4uyN0ZRen+aAQ=;
        b=lU6omnvZFV3Eyd/nRllE4TedXbMtNHTkcBanychyt6RlUb+Uz7pgpmU1rs6oYrq7fA
         qXaADxWlOkOT9yjA8GsRlrrAxzL7yVdEJKE9BtNva7zlDw5eRP/P7L2fRG6y3T4ik8iu
         AmoPIR3ThqHPdv0tRdGhe5gzRVfSjoJwUIInfEIESUDNG/hTtmg1EflmB+RsCfJUSJJT
         FtL26W3/zxNXeVlIRpIIU7SorV5pscA8g0k1W55tXpQYGj+a3WfgxZuE+o0Iw6GnRR3d
         ewOi2SRTvgTCXp5LaSUlMlHmoUgl9BHxtiPN6MNjuc56fSLKbkER7/XMiaLvbUWIPQGf
         pZ0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u27si10138209pgk.555.2019.02.25.11.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:33 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="147177877"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by fmsmga004.fm.intel.com with ESMTP; 25 Feb 2019 11:02:31 -0800
Subject: [PATCH 0/5] [v5] Allow persistent memory to be used like normal RAM
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com,keith.busch@intel.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:27 -0800
Message-Id: <20190225185727.BCBD768C@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a relatively small delta from v4.  The review comments seem
to be settling down, so it seems like we should start thinking about
how this might get merged.  Are there any objections to taking it in
via the nvdimm tree?

Dan Williams, our intrepid nvdimm maintainer has said he would
appreciate acks on these from relevant folks before merging them.
Reviews/acks on any in the series would be welcome, but the last
two especially are lacking any non-Intel acks:

	mm/resource: let walk_system_ram_range() search child resources
	dax: "Hotplug" persistent memory for use like normal RAM

Note: these are based on commit b20a7bfc2f9 in:

	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git for-5.1/devdax

Changes since v4:
 * Update powerpc resource return codes too, not just generic
 * Update dev_dax_kmem_remove() comment about resource "leaks"
 * Make HMM-related warning in __request_region() use %pR's
 * Add GPL export for memory_block_size_bytes() to fix build erroe
 * Add a FAQ in the documentation
 * Make resource.c hmm output a pr_warn() instead of pr_debug()
 * Minor CodingStyle tweaks
 * Allow device removal by making dev_dax_kmem_remove() return 0.
   Note that although the device goes away, the memory stays
   in-use, assigned and reserved.

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
be a waste.  However, if you have a user of a system that does not
care about persistence and wants all the RAM they can get, this
could allow you to use a RAM-based NVDIMM where it would otherwise
go unused.

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

== FAQ ==

Q: Will this break my NVDIMMs?

Intel's NVDIMMs were designed with use-cases like this in mind.
Using this feature on that hardware is not expected to affect
its service life.  If you have NVDIMMs from other sources, it
would be best to consult your hardware vendor to see if this
kind of use is appropriate.

Q: Will this leave secret data in memory after reboots?

Yes.  Data placed in persistent memory will remain there until
it is written again.  There are no specific mitigations for
this in the current patch set.  However, these kinds of issues
already exist in the kernel.  We leave secrets in "free" memory
all the time, and even across kexec-style reboots.  The only
difference here is that data can survive power cycles.

The kernel has built-in protections to ensure that sensitive
data is zero'd before being handed out to applications.  If
your persistent-memory data was available to an application,
it would almost certainly be a bug with or without this patch
set.

In addition, NVDIMMs have built-in encryption, functionally
similar to the disk passwords present on hard drives.  When
available, we suggest configuring NVDIMMs so that they are
locked on any power loss.

Q: What happens if memory errors are encountered?

If encountered at runtime, all the existing DRAM-based memory
error reporting and recovery is used: nothing changes.  The
only thing that's different is that the poison can be
persistent across reboots.  We suggest using the ndctl utility
to recover these locations for now.  Doing this automatically
could be a part of future enabling.  But, for now, please do
it from userspace.

== Testing Overview ==

Here's how I set up a system to test this thing:

1. Boot qemu with lots of memory: "-m 4096", for instance
2. Reserve 512MB of physical memory.  Reserving a spot a 2GB
   physical seems to work: memmap=512M!0x0000000080000000
   This will end up looking like a pmem device at boot.
3. When booted, convert fsdax device to "device dax":
	ndctl create-namespace -fe namespace0.0 -m dax
4. See patch 5 for instructions on binding the kmem driver
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
Cc: Keith Busch <keith.busch@intel.com>


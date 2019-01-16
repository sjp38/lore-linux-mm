Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F8AC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F395206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F395206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D01A08E0013; Wed, 16 Jan 2019 13:25:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C819C8E0004; Wed, 16 Jan 2019 13:25:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4D898E0013; Wed, 16 Jan 2019 13:25:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 739D28E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:39 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so5262533pfi.19
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:message-id;
        bh=2eqphlzBqS6EZCqpRYoZcRagdvyzph7xzJOz7FVdjVw=;
        b=I6WARpgvMbINd9/rM1SVhBa8uZhI4ArrbHzcw1qnIcYa3v5TgzKiB5bPDKQUO/y1+Y
         yHOH7VNlX/DRiLONTH/o57HJq4g3tA6JD6zwM/LAEoFAIOs1XHH6/L8M2wCjBI9H0feB
         9uc1XxpLhmR+F+SzMOn+ZxPX94jlQu93EySObg8CH4FAahJzPxMqzjm3l7h00HnkTZR5
         IOTGxgTWI1PyumIS1CLYXfc/vgzDCaAOVMVt8f5KYUatl0SBQbwJvWYpn/dBvVovh1eg
         ibTNXEn/gk0Z8QUROw+OZxYLusQMtcjQ8NJU7uNBxPcKcLdDvONme35aUwDBHBDNnzcS
         lMVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfDZbh952hjEnt7wqx9O9Uy9h6E/24w3E8apyTFzQYiSUYQYISP
	SZvQcULdWXn1d9QvOc+dw0NInPRiT6fjYDNh+ufoQn0gciMvcHEAaJV1aaHvC15uLH82wxdTrLk
	9PIp0AGKt8Ci7t9Nq/oZFz2HmY63durXfLcXRY2KMPaJTSFqcRz4Nitc6OJ2yz9O0DA==
X-Received: by 2002:a17:902:6b87:: with SMTP id p7mr11397291plk.282.1547663139099;
        Wed, 16 Jan 2019 10:25:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5EMHMctacNTAzXwsCs5xVY/K9srRUWxyfj06ED4lvw7qn4+bNribDlBHKayQK37iaRgKUq
X-Received: by 2002:a17:902:6b87:: with SMTP id p7mr11397225plk.282.1547663138119;
        Wed, 16 Jan 2019 10:25:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547663138; cv=none;
        d=google.com; s=arc-20160816;
        b=hcxwUsQ2rganawGmyMHpwfMcXZNRiu6V5ZRImAvl2AyZ0I4ILWWfnotoP53humvmC0
         IUD2TWn+EqRjaXXtA6OOuKGpGYPHOQd2mHYOY0v0WoAmgYaaTjuz8zlwjsKXHrC1nXv8
         0ZeFyT08qOzeCxPFJjpaWhlPq7hbXVA9CEnEAmwX3zkPTJ9fSKMRNWz8NnXMDU1pjc3M
         2ccR7hPCZ2Frmd4KJyVd5JvaoDSwnB8nCP7CE5jj91gslgAb3G6XwjTuvM0Deev7qjxy
         Yl+8N4E3cmF7AfUQ6Q/PDe22tIZmRQGZMWkqX82eqbD0BqS4xGHJmEkMZJWKO14TmFLa
         lnHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:from:cc:to:subject;
        bh=2eqphlzBqS6EZCqpRYoZcRagdvyzph7xzJOz7FVdjVw=;
        b=sQXVG8gQ9PsmvXmr/W31DyIwrvH9oQEvkP3n0mwFK6E/TOmFfokX3TDtH/hyVNL0Pt
         Xl64Wzuoj0l25Y21mOyqxbgPL0pq8lbn3hZwm0n7Ha05ZwpDhoZ+wEylyIeI2f0vHZs3
         imPY8AzOeSZixghYzUQyERFgv+jWXs5n2Gqu/WiBMsjzjRHONsIbNp4SWGmfR0pgXEeQ
         eU/Z7XAKG3QVMVDzlZZUpKeuVngQLRypGIgpw1Yv8lhBG8h7FgduQR1fquuV0rrsbpOy
         0LRPQavMrvzQxankWt1KkKEMbWujdzI8mabjGJlvlyyqUN478eJySVask31hqdx+e4fp
         ywiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 43si7067412plb.176.2019.01.16.10.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jan 2019 10:25:36 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,487,1539673200"; 
   d="scan'208";a="128296716"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga001.jf.intel.com with ESMTP; 16 Jan 2019 10:25:37 -0800
Subject: [PATCH 0/4] Allow persistent memory to be used like normal RAM
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-kernel@vger.kernel.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:18:59 -0800
Message-Id: <20190116181859.D1504459@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116181859.Z7-9R_Dzbb1z2EkrBgq4P4xgoFAo0bq4EF4pfs1ddiE@z>

I would like to get this queued up to get merged.  Since most of the
churn is in the nvdimm code, and it also depends on some refactoring
that only exists in the nvdimm tree, it seems like putting it in *via*
the nvdimm tree is the best path.

But, this series makes non-trivial changes to the "resource" code and
memory hotplug.  I'd really like to get some acks from folks on the
first three patches which affect those areas.

Borislav and Bjorn, you seem to be the most active in the resource code.

Michal, I'd really appreciate at look at all of this from a mem hotplug
perspective.

Note: these are based on commit d2f33c19644 in:

	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git libnvdimm-pending

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

This series adds a new "driver" to which pmem devices can be
attached.  Once attached, the memory "owned" by the device is
hot-added to the kernel and managed like any other memory.  On
systems with an HMAT (a new ACPI table), each socket (roughly)
will have a separate NUMA node for its persistent memory so
this newly-added memory can be selected by its unique NUMA
node.

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


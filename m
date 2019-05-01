Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3895C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A48EA20866
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="f+VLFHlW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48EA20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 378216B0005; Wed,  1 May 2019 15:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34FB26B0006; Wed,  1 May 2019 15:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23E3B6B0007; Wed,  1 May 2019 15:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 085776B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:18:51 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x23so67789qka.19
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=OAQ69X4DsUUmu2uoyueJmu5Yn4QG8MsXOg4ekEMYq7c=;
        b=o+TsT51lbmzdYAcku+k19+PZTU+8JdkQsnm/T8VCdkT38Zp+weYfWVBxrJjQgJdlG7
         NvoerMJzEC2YceVRIgU7Lyb+aBzTp+4V/7AIhwuYE0jnhB8M0jS6BK+y1KEnRvIr4Z0W
         bJONofuDTgl8kzxZNcQsx0KPDtIP2eqcUqy7bOiFEI/q/LBznW0HU+TeQuPgaJweJljo
         jRAg/JxGqpHF2Kq1kYZXWr6Ei8Rgbvbe41bGhoRdxam00plv60luCnG53CUs8FiPYS/r
         IlV322Xs1bA2XMI1uCF+EOqLAP2Gsk3KsYZqB3Ni3iD6hATdXltRdfQPHjoloDUA0GiB
         bpcQ==
X-Gm-Message-State: APjAAAVjlKwoqXKCdJF9VW36fTakDM71x/cjR1KxNwCmUdZm1jKCpfCx
	7TrjM6XChP/mLpoz0sAs1NLmIkw3xWUiovc1GUcRkai4/FBTfj9SU+CzIFrZuxeglLO8xCPpd6u
	z4JHrZ/SzQvrqGnTIY158GONTtXSyR/Mv7DfBHcQ1F1czvvTVk1GPE1+BTCR1FYzNzA==
X-Received: by 2002:aed:3647:: with SMTP id e65mr59568106qtb.44.1556738330725;
        Wed, 01 May 2019 12:18:50 -0700 (PDT)
X-Received: by 2002:aed:3647:: with SMTP id e65mr59568029qtb.44.1556738329397;
        Wed, 01 May 2019 12:18:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556738329; cv=none;
        d=google.com; s=arc-20160816;
        b=LVOoz050RaBEkDNUlpRblJ1ewJsxJFvwNsNxSBFvl1aXD3vchCHwHPcpVZChOo+Reu
         nPKmHtNo1ch4+Lsiq/9z5h7cETC1VW2GhXWH8DIh/mJL/47W7ObReokL4ikeJo42Q4Al
         JlKUrVA0cMM93KFuCUAbpjI81Ow5FxCTFshwrNbSHNWkz4Ur5AcqDTcSaSpyWtKDoWLK
         /CIs2/6UutHBAp9sDtYToIGGBZDVJGxoh0rx+XplS+63f8TGgUlHnt57Peenq4kTWviq
         az/JqZoZWHSecooXuHzbH8gd16iNBPptLWQcBLMSDFDHyAciMXbESfNUFDAxYXgToVg5
         eKEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=OAQ69X4DsUUmu2uoyueJmu5Yn4QG8MsXOg4ekEMYq7c=;
        b=N+1n9DyWBVgwpR5rpTl4oAd+niXw+vflZxnlw5b41XoSfnNoL2flaL0xERXmO1KGAs
         9OXqnFWcydRR3WG3FBHGoCOeb9kuRbp4zdiFVi/zc4r7dCtg2lBzaX3eG3ZqLc3zzHs2
         me01pElcTrivWDJ2kP+sXy23UE4X+PrlOTIyivzHw8V52MvSNfJBSOXtnyoE9pDhuFmH
         P55iNoEgUBuE5R76WC02YfKQAJxD7CrYKiN/ZLGGspDskIYfb45wfe82SrIPXCISKJic
         kLSNJ7cNejKhHB7Agc1oCpf35Ed3JysVcPNwT7TMfwBtvlUEA//A8lHaQjxRTM/elWKO
         NyAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=f+VLFHlW;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n66sor56789070qte.25.2019.05.01.12.18.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 12:18:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=f+VLFHlW;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=OAQ69X4DsUUmu2uoyueJmu5Yn4QG8MsXOg4ekEMYq7c=;
        b=f+VLFHlWekiPkTa0WJsOHu6qXrPme8uyI7C6FYdAM/ZJbXyW9yGBW+ehN7l854M2a1
         sD2ZcHq6fLNkAp7BSjgRXdCLPLNlfcSG+MsXJ9E6phebMZbuQXGwq1Gdvzv0ww7/HxBX
         6ai2BDJVLAi55EM5q5NZOv+Kmapu5KQ7y0W6G0YKVRoQdNZENRE26wj03jtLhrW0JbnC
         fdCsOv1XGOc1JcYJe7/cvrndachOYHniG0PtUXaJ0kLDvAM+69bi5jFbmjTGwHY8D3mb
         GB1SkcRRPWSjp7ncevM/tGHZtRLdSZz5m/FSvx41CzXWldx50mAHFat1UDjm20hf5Ovo
         BUNw==
X-Google-Smtp-Source: APXvYqzCyZTLdMErMvymnUr9OdlM5mz0rF37cxcBelrdS0nhZsEoaskJaHaEp/ddHKjZfP6CgNs73w==
X-Received: by 2002:aed:2124:: with SMTP id 33mr6517015qtc.35.1556738328959;
        Wed, 01 May 2019 12:18:48 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id x47sm12610946qth.68.2019.05.01.12.18.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:18:48 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v4 0/2] "Hotremove" persistent memory
Date: Wed,  1 May 2019 15:18:44 -0400
Message-Id: <20190501191846.12634-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
v4
- Addressed comments from Dave Hansen

v3
- Addressed comments from David Hildenbrand. Don't release
  lock_device_hotplug after checking memory status, and rename
  memblock_offlined_cb() to check_memblock_offlined_cb()

v2
- Dan Williams mentioned that drv->remove() return is ignored
  by unbind. Unbind always succeeds. Because we cannot guarantee
  that memory can be offlined from the driver, don't even
  attempt to do so. Simply check that every section is offlined
  beforehand and only then proceed with removing dax memory.

---

Recently, adding a persistent memory to be used like a regular RAM was
added to Linux. This work extends this functionality to also allow hot
removing persistent memory.

We (Microsoft) have an important use case for this functionality.

The requirement is for physical machines with small amount of RAM (~8G)
to be able to reboot in a very short period of time (<1s). Yet, there is
a userland state that is expensive to recreate (~2G).

The solution is to boot machines with 2G preserved for persistent
memory.

Copy the state, and hotadd the persistent memory so machine still has
all 8G available for runtime. Before reboot, offline and hotremove
device-dax 2G, copy the memory that is needed to be preserved to pmem0
device, and reboot.

The series of operations look like this:

1. After boot restore /dev/pmem0 to ramdisk to be consumed by apps.
   and free ramdisk.
2. Convert raw pmem0 to devdax
   ndctl create-namespace --mode devdax --map mem -e namespace0.0 -f
3. Hotadd to System RAM
   echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
   echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id
   echo online_movable > /sys/devices/system/memoryXXX/state
4. Before reboot hotremove device-dax memory from System RAM
   echo offline > /sys/devices/system/memoryXXX/state
   echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
5. Create raw pmem0 device
   ndctl create-namespace --mode raw  -e namespace0.0 -f
6. Copy the state that was stored by apps to ramdisk to pmem device
7. Do kexec reboot or reboot through firmware if firmware does not
   zero memory in pmem0 region (These machines have only regular
   volatile memory). So to have pmem0 device either memmap kernel
   parameter is used, or devices nodes in dtb are specified.

Pavel Tatashin (2):
  device-dax: fix memory and resource leak if hotplug fails
  device-dax: "Hotremove" persistent memory that is used like normal RAM

 drivers/dax/dax-private.h |   2 +
 drivers/dax/kmem.c        | 104 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 101 insertions(+), 5 deletions(-)

-- 
2.21.0


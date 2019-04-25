Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E04C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A94D7206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Ak4fyqQh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A94D7206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BE126B0003; Thu, 25 Apr 2019 13:54:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 845946B0005; Thu, 25 Apr 2019 13:54:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E416B0006; Thu, 25 Apr 2019 13:54:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB6F6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:54:45 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u66so602669qkh.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=KNp2ygAC3i6FKmzuLjHlJU1UqV45srtBI635+kYEZ+4=;
        b=NNnr8vMPkxhzUCdtfPVBvZgGiWtjw34AV4joYLMFtXiyxjpdMBVW+IDB3zxuLCy4vX
         95cfN9PIWpEZiPIoip64NiqW+YaIrN4p1QpRPYdZx5QoAOUbvTE3hosvZ2+NCEfkZxp1
         JN6AoHHxPLSZWYqs2gWvfn/kfxphmH7t3mHS1tGxxkVatwwLQHP86906/hDbJGUEOL4K
         7OHXfamJP7e0uKOEGEGY74Z/o9eh5TyIuccqzBbwzD1V5kwCixHnAwVWh2wkbtwqUiKy
         4gIltsTfG1e3z0nNh3EceAYELB954h7e0qTBji6W3XNY25h1k+rBw009swWuey3nag6G
         FuEA==
X-Gm-Message-State: APjAAAUr3nNwaHIav81IjViWQwFDRm4sVsQSaTUe+ezXnxp18DD4jlOm
	mOp1cXQLs/f0LkDW62VFNR1HSJgV8VHcgsByCBMC+Uf8oPGscfLqf8Ut3kd/tAUZLDe2f8AuDpJ
	d0xxq+FrPc8H/3xUguuu8lJWNxc7SeyivbmDuTtcgFqmkKLrGNS+LB7zmLBwDf7nb2g==
X-Received: by 2002:ac8:2da1:: with SMTP id p30mr8495156qta.72.1556214885000;
        Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
X-Received: by 2002:ac8:2da1:: with SMTP id p30mr8495071qta.72.1556214883672;
        Thu, 25 Apr 2019 10:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556214883; cv=none;
        d=google.com; s=arc-20160816;
        b=B35dChEjeXZh5pMkhweYOdq+0No4xNLfJ9l47td2DojvgsttUGWwWAqwxin4FGZjP5
         RzE6edhQ3Kns5jENYfnoLDvnVSc9RbjoxR9dmGHKE1I3FmbbIpAP2g+480KSiqB5XEfy
         F0TQKyh8XpmfT74xKGomr2qvAueSutaIstEpUSWWNSWovvajvyY8vO/lOwDUQHyyR68Q
         CZLaX3xHbVACAMOP5hw6AdsbbIUveodrXy0fvDmUXQRHkRDyelsW8s4uwLR9VRXPEDh3
         VMuu9DpQYAeWyNOy9Bq1GAkC2f/J8v0GEblh0JiiTwDYAKHQM8LPPjzV9LpYqVzmQAU1
         U7TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=KNp2ygAC3i6FKmzuLjHlJU1UqV45srtBI635+kYEZ+4=;
        b=PvVVC8mJwa6ayHmssXiDyPBVa2KiUnvvNKrbrTv8QZbRkUGO1g6AbFEgk2XHSab9/Y
         9xtCbebcq55uist2sRERscG8vqkYtH7RfUNp3hIWaDzEkHqf1kVeihS9ZFOT98R07Hhl
         Q/6/cmkTYZgrhsDpDUkfIVZ2IU9aco7l7H6XpBfcTn5ID+uwW4s9O/7G0nk9l9GDafKR
         sTgGfWjcBSQy9tE2IrSwbmGSF7kvXPhPPX3GM5OgLVPIQiG7pVDPP8rJk+vmKTrDYaWM
         F8Vm4Uz0tUTItI+LPiUU23GhtxXDEhJBHN9ZxzTEZ7spLs0WnR9vPNQAQFK5fAvUJgtt
         MtPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Ak4fyqQh;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g33sor31393527qta.55.2019.04.25.10.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 10:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Ak4fyqQh;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=KNp2ygAC3i6FKmzuLjHlJU1UqV45srtBI635+kYEZ+4=;
        b=Ak4fyqQhM8BxKff8fJEXf161Q1Q+odtuMhpTnuQUaVgZUmLE5+U2QcMZCNIxNsWpvr
         qxp/fnxisE1eVMxMg2cO54YQTaynDm09tw7mDW3edY33edar3pSTA/AbaTOZf5EmRzo0
         0e/ALVbFhIcBTc110AA1mRfkafLVwM6EMHHHXgIdUFtP1TR+BlePj6R4lsVx+dDuREhg
         zn2OAnyf6W73zJ490JzMZEY+fP3dVE+pmATmY7Fc42tbURkvCNhWTKISdRowzAiVVUQk
         aE/eMAcZYyHLGrML4/luEEL04zutva8eybz6doAmBmVNKUwEf2ooj/7ZlFTdgw+VoeRB
         a9rw==
X-Google-Smtp-Source: APXvYqyr9cp5oN/zmGj2t+i+id0VkfzdkKjneABv6Aqo2hHim6ED7PoKXjQJFBxK7dbJDJzvggzXyQ==
X-Received: by 2002:ac8:18ea:: with SMTP id o39mr11398232qtk.290.1556214883289;
        Thu, 25 Apr 2019 10:54:43 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 7sm5950641qtx.20.2019.04.25.10.54.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 10:54:42 -0700 (PDT)
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
Subject: [v3 0/2] "Hotremove" persistent memory
Date: Thu, 25 Apr 2019 13:54:38 -0400
Message-Id: <20190425175440.9354-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
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

 drivers/dax/dax-private.h |  2 +
 drivers/dax/kmem.c        | 99 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 96 insertions(+), 5 deletions(-)

-- 
2.21.0


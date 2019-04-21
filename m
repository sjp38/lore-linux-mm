Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6E9CC282DD
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6637120833
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="bOYUDjSw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6637120833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B860F6B0003; Sat, 20 Apr 2019 21:44:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B34E86B0006; Sat, 20 Apr 2019 21:44:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FBC46B0007; Sat, 20 Apr 2019 21:44:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82F036B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 21:44:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p26so8334768qtq.21
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=EUzJcCEPNzxrNRebVTHnadob9f3kjrf4lY7mTXNycVs=;
        b=Tu7BTb/8OiQfYg1k72FUmhBhEI4sZfR2/oT5CYzRwkfwA2Ob5GqJXmlNhaxoNX3Uxp
         jArGU+6kpd2tLgYXy6h/QaRXzlz+c3aIviUij/9gDu/rQUYfSZljUyUKauD1OiUo3yHo
         EbmJOEfwupE4Ae4AB6P4roQBnKem3rDD6plk+nKgpEGdpfY4CLJRoZBcCmrnUSEI9tNM
         h2t5VGaIQsLrQh1HRX1MOnncCClKWiFAXpNBZIroYgsAxfETaVYCc1Sf1E60hXCqiXXJ
         jB7YLbVWP43M935czsfL3amfYdbyGKel/uleA0meW5rXxNiAa0TuF2yvwIqSxq3y8t2X
         eMhg==
X-Gm-Message-State: APjAAAWzT0rCjuS0k4LVihqSSq5q3WcSdXZkrTHsYUDWvAu1BaX+412w
	zfR2nZ0PsqPV6Ub+om3l8LpQNstyMLd0eNfZwq8ghAADf0336KAL0JUSKmv11yFAlOxt6BKhrD2
	3BMIMobZuDEl5WIGFuztTkwJnsLlrtqMfOOl7l9azAYhv9fZnkj507S1vVO53W+jgBg==
X-Received: by 2002:ac8:6bc2:: with SMTP id b2mr947852qtt.316.1555811074101;
        Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
X-Received: by 2002:ac8:6bc2:: with SMTP id b2mr947818qtt.316.1555811072914;
        Sat, 20 Apr 2019 18:44:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555811072; cv=none;
        d=google.com; s=arc-20160816;
        b=BLRzUVuq11ARPyk/MtP9qNEyIS6gXW65mcxL9AKaeaR4HuTOM4ewSjBgZt2BL+qyGE
         bj7dGmIMkA+Q9RhMfXbIefMpdEdrORD8mJ9ZS49pLfD4DLs8oTSPGD2ARqSEBLph64S4
         pCZ0eICIidT6sCff0l2hBJbbku+4AbIfgCARMXBVPqzdcDpk6C5jUquVS5aZ2ZXfkCEl
         iMCTGdk139+ikvsBQuPDZQUDzJoZkUwQxPbIQGL/m3kD4i44d+vC4Y1w03djysxYQugt
         uhj0nV45vjT1LLBqtlZfmhb2GM7AA6lVIwF1gued+o6iCiCewOBthAiXriYVrrEQ8+B/
         C52g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=EUzJcCEPNzxrNRebVTHnadob9f3kjrf4lY7mTXNycVs=;
        b=sDRPnrvxEmfyjq6W0RUlSLursQDbSbFy3Kk6zpgx8C0BkU4YiiQWomUnAIB7nh38iP
         4CXMP2c956NTu/uFKBJS0Bqkq1m71TE0hLgDYPQU/yk4YymJ/GeDnQwsA2/juRCz5iWr
         MAZgiACeb3n7LYJJlR4whbuMhxy3Qs3NreESHOpCX+6nyTz8oybQ7LMQEjHPdhMYYclm
         TLdwetTMiyG2rz74RikDgrRHleJCLp/XaZgQFVkz0Hv/bl6l2DeQaRO7wALE1hq5bl+U
         gKof6t9XvPqbdUHtiTt7cxeglmyKRgTIS8hgjGOGZPATZXWJ7FzshKXylzV42LvwWR2B
         j9Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=bOYUDjSw;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s25sor7764542qva.34.2019.04.20.18.44.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 18:44:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=bOYUDjSw;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=EUzJcCEPNzxrNRebVTHnadob9f3kjrf4lY7mTXNycVs=;
        b=bOYUDjSwgmBCuOhOjvyCWmoDmaFqDR+hSTrbz3hZ5hEnHqcNcOESI6IDbjkMh53cxB
         G2x/gsrquZNFLSsxAj32qOqLpwi+fd3+7zvGuUT/KEdN8aYwoHOWBkQGVACwskgHLMqt
         3RPy+WduBUFt9ayw0hAttali1QHy8GoqBFz6WeuUUXLS0Cu7c1TkBjkjM6le/CDgWmDe
         xZWWQ851RPT7HzOEll57WaTFXsioXRv0XRhdEK5/qfxedQm63uqu26QBJLWmkYWWQ/Qm
         G+bddWTl2F+QpFsIAaDPs/kg0hNvLPx0miCR3utDHzsXmF+aBLXnELNjg0Jn811ftFkW
         c3RQ==
X-Google-Smtp-Source: APXvYqwGryHsI9e6T0GUZeIzujdwEDcVrbulda/4xor60EE28+izuI26XjYyBBq3siOOME8A8xbffQ==
X-Received: by 2002:a0c:b7a5:: with SMTP id l37mr9708401qve.94.1555811072426;
        Sat, 20 Apr 2019 18:44:32 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u1sm1385218qtj.50.2019.04.20.18.44.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 18:44:31 -0700 (PDT)
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
	jglisse@redhat.com
Subject: [v2 0/2] "Hotremove" persistent memory
Date: Sat, 20 Apr 2019 21:44:27 -0400
Message-Id: <20190421014429.31206-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
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
 drivers/dax/kmem.c        | 96 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 93 insertions(+), 5 deletions(-)

-- 
2.21.0


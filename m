Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35B41C73C65
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA7D72073D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="NYgWnJLb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA7D72073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 869348E0061; Tue,  9 Jul 2019 21:16:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818868E0032; Tue,  9 Jul 2019 21:16:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 706F38E0061; Tue,  9 Jul 2019 21:16:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB8D8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:16:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e32so780367qtc.7
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:16:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=PqeszyHnpa09JchLWcVjDqXY/gdBDHevYPDmL0qjCG8=;
        b=OMI8dQnTc3d8+Vj3os0UdC4UOcU/4PUdrdgBKPxEGMUbKu+NrbZaIGwiyNPe5KKUp6
         bWatD1CazCyNTJlusxgxqgXd+V8PQN4L7WR3LVcO5tj5ipaHWRrdKbXKrkhFA14DOmNY
         johKXvOFMMkmaBb4YELCRGHohEszcLgnJ9ZHAYZib7M9hoCGxMPiBtiGYcbFyASQIRox
         CyQ+/V+lmfBfVNx98ZiGZOmmwte5bmIm8ZZEGcyZQaBh0EyPgyDQpnaid+vmfAXGkDHY
         7XfvgHlPEx6fC6EeO4fXSFBB46jdpHGRJO0H7DWSOZfREFcKlj9KhOnqgYvSbqUKnz/E
         iTZg==
X-Gm-Message-State: APjAAAV/ifG+U3VFmXf7R2qrRmANFOpcOG5Ryc9y0XIZUkAtLBcQ2KMq
	Bca25/7hKmO7s2pIN43cUwpw4kU8h2wHhuqPpHqi5Og/jhI6m4f7hl1cpZdWpLzia4IpcvnunKp
	9hvHY9m/nnZ6ShPVk0sF+6nvpoxKB38nNmAo0Pt4iLh1qK0gEYJuX0jNgkxUnseOlsg==
X-Received: by 2002:ae9:f21a:: with SMTP id m26mr21639946qkg.430.1562721411062;
        Tue, 09 Jul 2019 18:16:51 -0700 (PDT)
X-Received: by 2002:ae9:f21a:: with SMTP id m26mr21639913qkg.430.1562721409941;
        Tue, 09 Jul 2019 18:16:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721409; cv=none;
        d=google.com; s=arc-20160816;
        b=OxYv6ll279y22q/84+TCqPxzAAMmmezoi1bMB5rbBnAwSG2Lj9GbkTghdXdgXAGIQL
         57G6shSj8CvxjhHgig8QSnb/k1u3cBCsMIjVTxkf47FVLFvimTlsNeFLvbuPpqX3+xY9
         PwvscahHDFiGd8f4+daaTY7Cj8BLi5GroaLH6+hTEmgSUg5mmw8YecToBuL5++JppKjT
         coCTijCaLXj4DPQVuvgJNKIqBzYuAKbRTwUjQtwr933tHgFDXvt80QTL5NT1cToQg/cV
         iU7l0tcdVzn9yi++ArkCehV6D8diGb/GACldg6v69Pu3RZZvQTgSSzxnnwBV+d8NtbdW
         leJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=PqeszyHnpa09JchLWcVjDqXY/gdBDHevYPDmL0qjCG8=;
        b=BsD5AyRHqYgZCTtpdNKrUAEaHMHVl2HXoCvpBTn3gtXQv9XLEAM+lO/LMNEGV0xdGG
         fmJf1tuVwF1YTd6H7Hd5PmOlslzEarCCmYPwIvlG/Bp5PCA0zOCgU67E3cgt12ul4Kla
         Vf9jHVDgEEJ2rEhpHIt06Z/FJOpDghddvmWhMrM2r04nKFYEaGneCr1rfArxacEGFAPY
         M85mbynKaEYEIGh0CNP0dT5a2cpW4M2xT/JMc4FHr1ce5oheFgYLpzzwTERtYJMykYwn
         clE6Yj6bUMBnVmxFuFBX5GqMAOWaQ+yoep0XmxtIWJ9t+TG13CLAF7/kBTpzikDSUEWx
         n2SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=NYgWnJLb;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r125sor268341qkd.29.2019.07.09.18.16.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 18:16:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=NYgWnJLb;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=PqeszyHnpa09JchLWcVjDqXY/gdBDHevYPDmL0qjCG8=;
        b=NYgWnJLbG4IKERgDp8Mh8rchqpvIRzQaOzF4bWc2NXG+eqFvzv5WLLXJh22Y51w5Vz
         o5hkqppdjfxAY+lffbn7o8xckUMuJcFpHvgEMfSqFSqpBj4swXlJYkJp+Qx1BZsFy3zx
         NxitqsOKFA568E0jamBAdwfoc2KarmcCjYBRmq7tpXPZYM9UWel6pBB9e0RdCbN1G7lM
         6k84/FODP8iMFFaxMzdhUE2L/A725PpjkSamO8doAbClan8mRDNB97MBDEik0/8ocSNz
         d+gQ2ptWEdcPoMakj2qwdSXqlVfZuL8x4wgGqvURqZy3xb4pceimmbiVvvVeNxBXFfps
         bTIA==
X-Google-Smtp-Source: APXvYqzHJ58xkPz/UnFmZw8DxydXmBaaklCvE3hDIpuyBcyWl2zdGdbL4YcSPkWWV6dS4LNlSnmtaw==
X-Received: by 2002:a37:9481:: with SMTP id w123mr20792761qkd.319.1562721409590;
        Tue, 09 Jul 2019 18:16:49 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u7sm260057qta.82.2019.07.09.18.16.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Jul 2019 18:16:48 -0700 (PDT)
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
Subject: [v7 0/3] "Hotremove" persistent memory
Date: Tue,  9 Jul 2019 21:16:44 -0400
Message-Id: <20190710011647.10944-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
v7
- Added Dan Williams Reviewed-by to the last patch, and small change to
  dev_err() otput format as was suggested by Dan.

v6
- A few minor changes and added reviewed-by's.
- Spent time studying lock ordering issue that was reported by Vishal
  Verma, but that issue already exists in Linux, and can be reproduced
  with exactly the same steps with ACPI memory hotplugging.

v5
- Addressed comments from Dan Williams: made remove_memory() to return
  an error code, and use this function from dax.

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


Pavel Tatashin (3):
  device-dax: fix memory and resource leak if hotplug fails
  mm/hotplug: make remove_memory() interface useable
  device-dax: "Hotremove" persistent memory that is used like normal RAM

 drivers/dax/dax-private.h      |  2 ++
 drivers/dax/kmem.c             | 46 +++++++++++++++++++++---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 64 +++++++++++++++++++++++-----------
 4 files changed, 92 insertions(+), 28 deletions(-)

-- 
2.22.0


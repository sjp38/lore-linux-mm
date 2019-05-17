Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00B1BC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A665D2133D
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="K88wU7ZU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A665D2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DE426B0003; Fri, 17 May 2019 17:54:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 366B06B0005; Fri, 17 May 2019 17:54:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207DC6B0006; Fri, 17 May 2019 17:54:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F26376B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:54:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w34so7775717qtc.16
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:54:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=cdLOc+SMSQhawrzrqz+8WbUA4suNHX51mq88wClVqBo=;
        b=q0DDIBrAVk7yE0K2v71b3w0V7g2hdR2G2RliQkoqt1dkZQdw1k8IjctKK0eoUSHZ4U
         uIfEI9VfqdEB3haGIx7n+8pnM0UKpx5ZsOoAZNsbnp1rsDM4czBr+ROQiMzhIn/sLNeE
         5FXDobLP6FYwFUJoYOMvJ5MMehvTOrYORCrphxUM7w0qn4LYyyKPf3UqPt05DmExVFgX
         L6+vTIKzgkakrXoE9mYW4Ogmjx8zkmTKZHzkncam/QsI4iqM7jiM168bZMBT0582ZZWg
         b8rx/Dy+NsqRymiQNjLdM7OJ0TjPiAWXMJfkj1aMIH3ttHYQtVJQvIkO+oqjGSEXhR0e
         TAYA==
X-Gm-Message-State: APjAAAWYW6S47BAy3UD4wCgIbhT+00KYJ6SD6PHMTGyUUeREnU+7ao1q
	CogTJ34udx7EdweBbqvnFdPUg1ih1Ym25IFcVIiqUZ8CoTPq8mhQKjT2Cul+W0dVQ4fcUAu+Swf
	BTDiRmQpFgLQZZMYnlq5PjOSNFE1ZSCRcfAqr85pDIjk0lgDXMnTz8+yokHEdz7O6vA==
X-Received: by 2002:a37:a24b:: with SMTP id l72mr46155477qke.166.1558130081722;
        Fri, 17 May 2019 14:54:41 -0700 (PDT)
X-Received: by 2002:a37:a24b:: with SMTP id l72mr46155442qke.166.1558130081008;
        Fri, 17 May 2019 14:54:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558130081; cv=none;
        d=google.com; s=arc-20160816;
        b=CXrlVjwAEWfOt6HdU/uMzMrIeksTYJ+DK2sMWHiJDkxzM7bCJQVOQ+R5sITaekf9pW
         HyUx/3oJy4sgfit7MUZ5cQJ7+Fr4/Z+KvT6Py2fs5chu1wC681gO2EnoNsFAQHvllAeq
         e1PK7oMaWeOCCVl59vsdY4TWjQp0x0XUVfCWa+CkEdkPe9CnQuMygvtfjhFQ/DS4ei5D
         ioA6Rp0hGZoVqpqzWgP4+QRyKnoTaAGjEssBd+5btL7maBzbTAzz2MfgJrgQzhtNURZd
         /GgaHvYUaBgLh6nSJFxOyf4s6ddXElI+gAdkL3OzrRL7IXMHkSDkPsXLUI+wb/lj3RRJ
         7lyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=cdLOc+SMSQhawrzrqz+8WbUA4suNHX51mq88wClVqBo=;
        b=hoTEWooKbjk94se18ZhFOJmt5G3otHe41DVZs0Gsu/gELRSthzJZhPAYCbIm94vbfE
         47ZJ+nT6y7FM9llEMxCOzB/Xj3iNsZWDCgHyGk1IzYCv4bseu0td/kwnLwpN6wBqQHWb
         U6eRuhlSimZoJQIEuceskSHGi3enOZ7PqxrUe7JrOt5zJYXSYrO4WlNt5bGpaH67o3Op
         g+B4SVhNxr39V4dun+E2NOF7g8gGSu+6e5KuemX2mDD8gluCMgROdZCcmLhA4DWDhoqP
         Tfepcswke2826VYkX5EDOpp8EibOFTIC83zuIeT41sTPNv6WzmIyKl22QC0FJsdNkojm
         d3PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=K88wU7ZU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j41sor13221249qtj.55.2019.05.17.14.54.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 14:54:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=K88wU7ZU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=cdLOc+SMSQhawrzrqz+8WbUA4suNHX51mq88wClVqBo=;
        b=K88wU7ZUdBNygUX/4hEfsdd3b5xw9qN0XpxIE3OHk+2F1YuEDlAXKpNWqMhqXami4k
         Rq+M0mPPlolFRa1Iqmv4IcS37oJ6ecEX1N9eDvHI1FXqYVx7PRBWSHcO938AyPfAy6n2
         XgwYJuNGHk+mmQXu6QNfgphRBW3Qw+ggZG4Zn/k3agq3jrmMX47lHDL3hgntkK3tlrFe
         MzTPFgiV5z2kkoxd2Czl5jcUGWo/Rp0FKQZ5nPu4hugHjmx6/T5MlDD54tQFv+ms1ZFi
         6hnAso8+98I16B6QtlV21IU3kzIM2/pM8GLq4UAnkoEW0JAODRiqXdfFAoS2nAe3TANG
         3GFQ==
X-Google-Smtp-Source: APXvYqzDq7uOxY4NjgPSre5B/TFHOi6ZL1hpPZUFQQ6FbqLBzaj9XaKLtw0yJDUtXZwxmvAQtpAwaQ==
X-Received: by 2002:ac8:1b0a:: with SMTP id y10mr47723392qtj.91.1558130080605;
        Fri, 17 May 2019 14:54:40 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n36sm6599813qtk.9.2019.05.17.14.54.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:54:39 -0700 (PDT)
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
Subject: [v6 0/3] "Hotremove" persistent memory
Date: Fri, 17 May 2019 17:54:35 -0400
Message-Id: <20190517215438.6487-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:

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
2.21.0


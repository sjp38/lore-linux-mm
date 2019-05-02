Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 085C0C04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F49121734
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="FJISljxN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F49121734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27C76B0003; Thu,  2 May 2019 14:43:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD89B6B0005; Thu,  2 May 2019 14:43:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEF286B0007; Thu,  2 May 2019 14:43:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B02C66B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:43:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id u65so3271850qkd.17
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:43:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=xoemE8OPi9tqBHaKmVDMP6fqzg3JRjWrdojq7V/9jr4=;
        b=Lep2qqX3+WP8THGeC+hdlfrDGcc3RS3SPc/DD/Su1e/iH/xjsQhTaRFuexF+bf2I9M
         TdEbNs1MBFiqeJPTuP7mjCq7Ld+q3KyzZ2kEs27AIgFozzpx0eaeShFEueiqKIWQQ4AG
         FmcDvK1OKj+gaQD/a52enxsSJru1TAoMRYS+pBQ+JmTARx4ShAid0rDOqAqBW7C7II2z
         V8C9VA7L5rqJ/nt1g9w9mqmoOvTmrh1pkmgm2sMFYbLF8FIXGYns5NRHPeXiSAcGpC2t
         LKYYP8NzHL0lPnGbL8fe7hDMA9A9QjHWKqbjA00Zut/Yy3vQ/lshyTvuc8JlvwnWbxo5
         f+TQ==
X-Gm-Message-State: APjAAAUF0MmjN1o5ZhypzLDqoHa8SokdQI16Kvx6Mly91csAuqoigr4x
	2mnNhSBDR+UArf3WtvuxDA/qqBL1EKWTbJgkcbVvOdridVYP9b+tiBzbyR0ACKVL7MuUTi3o6eJ
	POU1qUYlFYNY/ceO0vB2SVfarQ/cWcay0WjuYSc9T86yN6Xo1+uUR8pPd9hpPbRsLbQ==
X-Received: by 2002:ac8:44cb:: with SMTP id b11mr4473720qto.155.1556822621362;
        Thu, 02 May 2019 11:43:41 -0700 (PDT)
X-Received: by 2002:ac8:44cb:: with SMTP id b11mr4473639qto.155.1556822620230;
        Thu, 02 May 2019 11:43:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556822620; cv=none;
        d=google.com; s=arc-20160816;
        b=Ll3h8XeTvp9YPr92NkKtGl2BYIW8RfXJOzkhRPqQwQc2VMmr4UGkFfwhebmBmPKix1
         uIdPYIPt3+qb5hUnKbS5wRvgC3PiIQ3z264G0j1sLYNGx+FyVsgy3mD/pwPdNwIvNNS9
         BlDPsygJ6ugR1r+Ms+QvPYb3gCRrr07adsod+sFuWHRmXoWicT2AcnLodnLebtazt6WG
         3JaEMlrL4hUz6UsQ0vVGXYIGAcdk9eLuA60/MmXCJgn4/e+OkRQsOLTTYD9cHat1LfUN
         upSGLWhFRPLdvfG7voijWLlW1uz//AnUNe3ur2UYZ3BgwdkQ110UoqPf6NECwuOCoHK1
         +6Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=xoemE8OPi9tqBHaKmVDMP6fqzg3JRjWrdojq7V/9jr4=;
        b=a/ydx+0w6ypEBtFyQXOc2mIlwJwiIuw/dMPJSflv4QIiibrOExhVqmay1PWGRNF9EL
         RIfvrER1Zw9bt+vfZJW1eCMSb3vdCbKcv1tUyZiX4JbGx83Mpdx40ujc/R94u7FF+TcV
         iV5+n4G/Q+wNnVvfgjVfPtzKcz1p0oumqwgnkBzX4QzUMnrGVvk7z4xwnkXyzoXxaxGd
         810ebtvUiN9ae6GXOwYd29gPF11S3gpemnA/7jyShw+OQVcT1swLEbfVL1UBhRI2Pq6M
         vgjnndvLzhvhSr5Vj4C5p2YWNn6YEz9UdxIRxLdnlAQMpxtCe4EpYDXxVFVd9t2zIwQH
         mPRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FJISljxN;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y10sor4949467qtm.18.2019.05.02.11.43.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 11:43:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FJISljxN;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xoemE8OPi9tqBHaKmVDMP6fqzg3JRjWrdojq7V/9jr4=;
        b=FJISljxNrMpf4BKlSGlFeUIV8YCdFaNtpEv6AsymPhEDpG/AYIOG564YnNgyiSZWYs
         er3AMBJemBc5rus9Wxn9a3q92pMjyIY35YjJBnrjKns6nNaTIL3+Kv7qqcHlJw75OsYD
         zPDMcCNUOhEBpj14TxzAHyzuYb/L0bCZe37EIL49iHNzw/vfuyUmJHW9EOpqOPC5nnS+
         tfWu9kNx5xZbaPzjIk5/kJO7U65ZWbAy3mcTyDUBHmXgAxsW8gu6gSS7xABffa88s0Rf
         5V9s4F2DpoSRTPMKZSEB51TgBtnUSFEFXIVol4hVNm8XpV5s8aQBbDGBGq5AbPhUbIvu
         FIvQ==
X-Google-Smtp-Source: APXvYqydvQA3tm1YLVyZkJR+Xcl7phv6H18jB1wWNP5r4MBakwaedC5LCXAOSAq7RroNt91CriKhcg==
X-Received: by 2002:aed:3512:: with SMTP id a18mr4319879qte.181.1556822619826;
        Thu, 02 May 2019 11:43:39 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 8sm25355751qtr.32.2019.05.02.11.43.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 11:43:39 -0700 (PDT)
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
Subject: [v5 0/3] "Hotremove" persistent memory
Date: Thu,  2 May 2019 14:43:34 -0400
Message-Id: <20190502184337.20538-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
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
 drivers/dax/kmem.c             | 46 ++++++++++++++++++++++---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 61 ++++++++++++++++++++++------------
 4 files changed, 89 insertions(+), 28 deletions(-)

-- 
2.21.0


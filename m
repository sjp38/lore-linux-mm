Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4366B026B
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7-v6so25094962pfj.6
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:51 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c81-v6si37899551pfb.153.2018.10.22.13.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:50 -0700 (PDT)
Subject: [PATCH 9/9] dax/kmem: actually enable the code in Makefile
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:32 -0700
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Message-Id: <20181022201332.FC3B5EB7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com


Most of the new code was dead up to this point.  Now that
all the pieces are in place, enable it.

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

---

 b/drivers/dax/Makefile |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/dax/Makefile~dax-kmem-makefile drivers/dax/Makefile
--- a/drivers/dax/Makefile~dax-kmem-makefile	2018-10-22 13:12:25.068930384 -0700
+++ b/drivers/dax/Makefile	2018-10-22 13:12:25.071930384 -0700
@@ -2,7 +2,9 @@
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
 obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem.o
+obj-$(CONFIG_DEV_DAX_PMEM) += dax_kmem.o
 
 dax-y := super.o
 dax_pmem-y := pmem.o
+dax_kmem-y := kmem.o
 device_dax-y := device.o
_

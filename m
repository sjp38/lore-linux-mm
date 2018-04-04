Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 342856B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:04:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u7-v6so11143609plr.13
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:04:48 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e4si4222884pfa.103.2018.04.04.08.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:03:54 -0700 (PDT)
Date: Wed, 4 Apr 2018 23:03:39 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] trace_uprobe: trace_uprobe_mmap() can be static
Message-ID: <20180404150339.GA48831@ivb43>
References: <20180404083110.18647-7-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404083110.18647-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com


Fixes: d8d4d3603b92 ("trace_uprobe: Support SDT markers having reference count (semaphore)")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 trace_uprobe.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 2502bd7..49a8673 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -998,7 +998,7 @@ static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
 }
 
 /* Called with down_write(&vma->vm_mm->mmap_sem) */
-void trace_uprobe_mmap(struct vm_area_struct *vma)
+static void trace_uprobe_mmap(struct vm_area_struct *vma)
 {
 	struct trace_uprobe *tu;
 	unsigned long vaddr;

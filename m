Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ED1E36B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 06:57:16 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so2544347pab.34
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 03:57:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xn1si4786158pbc.158.2014.03.06.03.57.15
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 03:57:16 -0800 (PST)
Date: Thu, 06 Mar 2014 19:57:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 441/458] undefined reference to
 `__bad_size_call_parameter'
Message-ID: <53186298.PKzXRwBAXOkhQnP7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   0ffb2fe7b9c30082876fa3a17da018bf0632cf03
commit: 2bdfb1fe44a9a1739c87de965bc0fc408d96f2fe [441/458] s390: replace __get_cpu_var uses
config: make ARCH=s390 allmodconfig

All error/warnings:

   arch/s390/built-in.o: In function `s390_handle_mcck':
>> (.text+0x9416): undefined reference to `__bad_size_call_parameter'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

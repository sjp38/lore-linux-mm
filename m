Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CB62B6B00DC
	for <linux-mm@kvack.org>; Mon,  5 May 2014 22:31:27 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so3438044pad.30
        for <linux-mm@kvack.org>; Mon, 05 May 2014 19:31:27 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id td10si10433328pac.386.2014.05.05.19.31.25
        for <linux-mm@kvack.org>;
        Mon, 05 May 2014 19:31:26 -0700 (PDT)
Date: Tue, 06 May 2014 10:30:05 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 16/389] fs/notify/fanotify/fanotify_user.c:701:2:
 error: implicit declaration of function 'personality'
Message-ID: <5368492d.DPw+MmrkNUrQmF0Y%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Woods <wwoods@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a51cc1787cdef3f17536d6a6dc1edd0e7a85988f
commit: efeebf123cce39e502749636d92de8f0a2b39b41 [16/389] fanotify: fix -EOVERFLOW with large files on 64-bit
config: make ARCH=ia64 allmodconfig

All error/warnings:

   fs/notify/fanotify/fanotify_user.c: In function 'SYSC_fanotify_init':
>> fs/notify/fanotify/fanotify_user.c:701:2: error: implicit declaration of function 'personality' [-Werror=implicit-function-declaration]
>> fs/notify/fanotify/fanotify_user.c:701:1: error: 'PER_LINUX32' undeclared (first use in this function)
   fs/notify/fanotify/fanotify_user.c:701:1: note: each undeclared identifier is reported only once for each function it appears in
   cc1: some warnings being treated as errors

vim +/personality +701 fs/notify/fanotify/fanotify_user.c

   695		if (unlikely(!oevent)) {
   696			fd = -ENOMEM;
   697			goto out_destroy_group;
   698		}
   699		group->overflow_event = &oevent->fse;
   700	
 > 701		if (force_o_largefile())
   702			event_f_flags |= O_LARGEFILE;
   703		group->fanotify_data.f_flags = event_f_flags;
   704	#ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

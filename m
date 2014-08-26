Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 24A3F6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 08:54:59 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so22275837pde.23
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 05:54:58 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f2si3911404pdk.241.2014.08.26.05.54.57
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 05:54:58 -0700 (PDT)
Date: Tue, 26 Aug 2014 20:55:44 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 155/172] undefined reference to
 `watchdog_hardlockup_detector_is_enabled'
Message-ID: <53fc83d0.eS2Nhff1ydj9/9qj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ulrich Obergfell <uobergfe@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Don Zickus <dzickus@redhat.com>, Andrew Jones <drjones@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9ff078807eb23bbd93e8a09e4d323b4246a2a414
commit: dd537b4f62ee02ada2c10246b9e82eb20287452b [155/172] kernel/watchdog.c: control hard lockup detection default
config: make ARCH=sparc64 defconfig

All error/warnings:

   kernel/built-in.o: In function `proc_dowatchdog':
>> (.text+0x6a5e0): undefined reference to `watchdog_hardlockup_detector_is_enabled'
   kernel/built-in.o: In function `proc_dowatchdog':
>> (.text+0x6a668): undefined reference to `watchdog_enable_hardlockup_detector'
   kernel/built-in.o: In function `proc_dowatchdog':
>> (.text+0x6a75c): undefined reference to `watchdog_enable_hardlockup_detector'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

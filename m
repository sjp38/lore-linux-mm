Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 638DE6B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:03:01 -0500 (EST)
Date: Fri, 16 Nov 2012 22:02:15 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [glommer-memcg:die-cpuacct 6/6] fair.c:(.text+0x5b96d): undefined reference to `task_group_charge'
Message-ID: <50a64767.TuSNeB5WQm2WTglP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git die-cpuacct
head:   feb0b5dd821a5c66f5e75bdcb071ce6c135a1b3c
commit: feb0b5dd821a5c66f5e75bdcb071ce6c135a1b3c [6/6] cpuacct: don't actually do anything.
config: make ARCH=x86_64 allmodconfig

All error/warnings:

kernel/built-in.o: In function `update_curr':
fair.c:(.text+0x5b96d): undefined reference to `task_group_charge'
kernel/built-in.o: In function `update_curr_rt':
rt.c:(.text+0x6210f): undefined reference to `task_group_charge'

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

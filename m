Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B92646B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:58:04 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so2572341pab.30
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:58:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ii3si7918368pbb.79.2014.06.19.19.58.03
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:58:03 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:58:00 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 131/230] kernel/events/uprobes.c:330:1: warning: label
 'put_new' defined but not used
Message-ID: <20140620025800.GA20022@localhost>
References: <53a39bf2./ABA70PSoAso2CXo%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a39bf2./ABA70PSoAso2CXo%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 9e458f8e3d973f459b8c8fef50e15012764f7998 [131/230] mm-memcontrol-rewrite-charge-api-fix
config: make ARCH=i386 allyesconfig

All warnings:

   kernel/events/uprobes.c: In function 'uprobe_write_opcode':
>> kernel/events/uprobes.c:330:1: warning: label 'put_new' defined but not used [-Wunused-label]
    put_new:
    ^

vim +/put_new +330 kernel/events/uprobes.c

2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  314  	ret = -ENOMEM;
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  315  	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  316  	if (!new_page)
9f92448c kernel/events/uprobes.c Oleg Nesterov     2012-07-29  317  		goto put_old;
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  318  
9e458f8e kernel/events/uprobes.c Andrew Morton     2014-06-20  319  //	if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))
9e458f8e kernel/events/uprobes.c Andrew Morton     2014-06-20  320  //		goto put_new;
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  321  
29dedee0 kernel/events/uprobes.c Oleg Nesterov     2014-05-05  322  	__SetPageUptodate(new_page);
3f47107c kernel/events/uprobes.c Oleg Nesterov     2013-03-24  323  	copy_highpage(new_page, old_page);
3f47107c kernel/events/uprobes.c Oleg Nesterov     2013-03-24  324  	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  325  
c517ee74 kernel/events/uprobes.c Oleg Nesterov     2012-07-29  326  	ret = __replace_page(vma, vaddr, old_page, new_page);
29dedee0 kernel/events/uprobes.c Oleg Nesterov     2014-05-05  327  	if (ret)
29dedee0 kernel/events/uprobes.c Oleg Nesterov     2014-05-05  328  		mem_cgroup_uncharge_page(new_page);
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  329  
9f92448c kernel/events/uprobes.c Oleg Nesterov     2012-07-29 @330  put_new:
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  331  	page_cache_release(new_page);
9f92448c kernel/events/uprobes.c Oleg Nesterov     2012-07-29  332  put_old:
7b2d81d4 kernel/uprobes.c        Ingo Molnar       2012-02-17  333  	put_page(old_page);
7b2d81d4 kernel/uprobes.c        Ingo Molnar       2012-02-17  334  
5323ce71 kernel/events/uprobes.c Oleg Nesterov     2012-06-15  335  	if (unlikely(ret == -EAGAIN))
5323ce71 kernel/events/uprobes.c Oleg Nesterov     2012-06-15  336  		goto retry;
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  337  	return ret;
2b144498 kernel/uprobes.c        Srikar Dronamraju 2012-02-09  338  }



---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

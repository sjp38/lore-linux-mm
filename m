Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5330D6B0023
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 05:47:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k17so12305140pfj.10
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 02:47:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 2-v6si12521256pla.436.2018.04.02.02.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 02:47:09 -0700 (PDT)
Date: Mon, 2 Apr 2018 17:45:48 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <201804021616.HByAT8F9%fengguang.wu@intel.com>
References: <1522647064-27167-2-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522647064-27167-2-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org

Hi Rao,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on rcu/rcu/next]
[also build test WARNING on v4.16 next-20180329]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/rao-shoaib-oracle-com/Move-kfree_rcu-out-of-rcu-code-and-use-kfree_bulk/20180402-135939
base:   https://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu.git rcu/next
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/init.h:134:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/init.h:135:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/init.h:268:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/init.h:269:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/printk.h:200:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:32:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:34:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:37:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:38:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:40:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:42:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:43:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:45:5: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:46:5: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/mem_encrypt.h:49:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/qspinlock.h:53:32: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/workqueue.h:646:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/workqueue.h:647:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/wait_bit.h:41:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/numa.h:34:12: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/numa.h:35:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/numa.h:62:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/vmalloc.h:64:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/vmalloc.h:173:8: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/vmalloc.h:174:8: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/fixmap.h:174:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/fixmap.h:176:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/fixmap.h:178:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/fixmap.h:180:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/apic.h:254:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/apic.h:430:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/io_apic.h:184:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:113:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:125:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:126:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:110:33: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:112:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:114:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:118:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:126:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:63:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:64:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:65:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:66:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/memory_hotplug.h:221:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/mmzone.h:1292:15: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2421:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2422:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:3329:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/hrtimer.h:497:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/kmemleak.h:29:33: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:29:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:30:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/pgtable.h:28:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:135:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:758:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/mm.h:1753:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/mm.h:1941:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/mm.h:2083:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/mm.h:2671:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/swiotlb.h:39:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/swiotlb.h:124:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/swiotlb.h:9:12: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/swiotlb.h:10:12: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/swiotlb.h:11:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/swiotlb.h:12:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/dma-contiguous.h:85:5: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/vdso.h:44:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/cred.h:167:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/nsproxy.h:74:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/io.h:47:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:302:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:4056:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/ftrace.h:462:6: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:59:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:95:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:120:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:150:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:191:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:231:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:285:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/bpf.h:315:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/xdp.h:28:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/xdp.h:53:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/xdp.h:155:1: sparse: attribute 'indirect_branch': unknown attribute
   include/trace/events/xdp.h:190:1: sparse: attribute 'indirect_branch': unknown attribute
   kernel/bpf/core.c:1546:31: sparse: incorrect type in return expression (different address spaces) @@    expected struct bpf_prog_array [noderef] <asn:4>* @@    got sn:4>* @@
   kernel/bpf/core.c:1546:31:    expected struct bpf_prog_array [noderef] <asn:4>*
   kernel/bpf/core.c:1546:31:    got void *
   kernel/bpf/core.c:1550:17: sparse: incorrect type in return expression (different address spaces) @@    expected struct bpf_prog_array [noderef] <asn:4>* @@    got rray [noderef] <asn:4>* @@
   kernel/bpf/core.c:1550:17:    expected struct bpf_prog_array [noderef] <asn:4>*
   kernel/bpf/core.c:1550:17:    got struct bpf_prog_array *<noident>
>> kernel/bpf/core.c:1558:9: sparse: cast removes address space of expression
   kernel/bpf/core.c:1621:34: sparse: incorrect type in initializer (different address spaces) @@    expected struct bpf_prog **prog @@    got struct bpf_prog *struct bpf_prog **prog @@
   kernel/bpf/core.c:1621:34:    expected struct bpf_prog **prog
   kernel/bpf/core.c:1621:34:    got struct bpf_prog *[noderef] <asn:4>*<noident>
   kernel/bpf/core.c:1644:31: sparse: incorrect type in assignment (different address spaces) @@    expected struct bpf_prog **existing_prog @@    got struct bpf_prog *struct bpf_prog **existing_prog @@
   kernel/bpf/core.c:1644:31:    expected struct bpf_prog **existing_prog
   kernel/bpf/core.c:1644:31:    got struct bpf_prog *[noderef] <asn:4>*<noident>
   kernel/bpf/core.c:1666:15: sparse: incorrect type in assignment (different address spaces) @@    expected struct bpf_prog_array *array @@    got struct bpf_prog_astruct bpf_prog_array *array @@
   kernel/bpf/core.c:1666:15:    expected struct bpf_prog_array *array
   kernel/bpf/core.c:1666:15:    got struct bpf_prog_array [noderef] <asn:4>*
   kernel/bpf/core.c:1672:31: sparse: incorrect type in assignment (different address spaces) @@    expected struct bpf_prog **[assigned] existing_prog @@    got structstruct bpf_prog **[assigned] existing_prog @@
   kernel/bpf/core.c:1672:31:    expected struct bpf_prog **[assigned] existing_prog
   kernel/bpf/core.c:1672:31:    got struct bpf_prog *[noderef] <asn:4>*<noident>
   include/trace/events/bpf.h:59:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:95:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:120:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:191:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:231:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:285:1: sparse: Using plain integer as NULL pointer
   include/trace/events/bpf.h:315:1: sparse: too many warnings

vim +1558 kernel/bpf/core.c

324bda9e6c Alexei Starovoitov 2017-10-02  1542  
324bda9e6c Alexei Starovoitov 2017-10-02  1543  struct bpf_prog_array __rcu *bpf_prog_array_alloc(u32 prog_cnt, gfp_t flags)
324bda9e6c Alexei Starovoitov 2017-10-02  1544  {
324bda9e6c Alexei Starovoitov 2017-10-02  1545  	if (prog_cnt)
324bda9e6c Alexei Starovoitov 2017-10-02 @1546  		return kzalloc(sizeof(struct bpf_prog_array) +
324bda9e6c Alexei Starovoitov 2017-10-02  1547  			       sizeof(struct bpf_prog *) * (prog_cnt + 1),
324bda9e6c Alexei Starovoitov 2017-10-02  1548  			       flags);
324bda9e6c Alexei Starovoitov 2017-10-02  1549  
324bda9e6c Alexei Starovoitov 2017-10-02  1550  	return &empty_prog_array.hdr;
324bda9e6c Alexei Starovoitov 2017-10-02  1551  }
324bda9e6c Alexei Starovoitov 2017-10-02  1552  
324bda9e6c Alexei Starovoitov 2017-10-02  1553  void bpf_prog_array_free(struct bpf_prog_array __rcu *progs)
324bda9e6c Alexei Starovoitov 2017-10-02  1554  {
324bda9e6c Alexei Starovoitov 2017-10-02  1555  	if (!progs ||
324bda9e6c Alexei Starovoitov 2017-10-02  1556  	    progs == (struct bpf_prog_array __rcu *)&empty_prog_array.hdr)
324bda9e6c Alexei Starovoitov 2017-10-02  1557  		return;
324bda9e6c Alexei Starovoitov 2017-10-02 @1558  	kfree_rcu(progs, rcu);
324bda9e6c Alexei Starovoitov 2017-10-02  1559  }
324bda9e6c Alexei Starovoitov 2017-10-02  1560  

:::::: The code at line 1558 was first introduced by commit
:::::: 324bda9e6c5add86ba2e1066476481c48132aca0 bpf: multi program support for cgroup+bpf

:::::: TO: Alexei Starovoitov <ast@fb.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

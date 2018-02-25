Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66A1D6B0006
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 22:34:47 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h193so6332952pfe.14
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 19:34:47 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g6-v6si1011687plj.565.2018.02.24.19.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Feb 2018 19:34:45 -0800 (PST)
Date: Sun, 25 Feb 2018 11:34:19 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 2/2] net: mark slab's used by ss as UAPI
Message-ID: <201802251145.AJHH4acY%fengguang.wu@intel.com>
References: <20180224190454.23716-3-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180224190454.23716-3-sthemmin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: kbuild-all@01.org, davem@davemloft.net, willy@infradead.org, netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>

Hi Stephen,

I love your patch! Perhaps something to improve:

[auto build test WARNING on net/master]
[also build test WARNING on v4.16-rc2 next-20180223]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Stephen-Hemminger/mark-some-slabs-as-visible-not-mergeable/20180225-084344
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
   include/linux/memory_hotplug.h:221:13: sparse: attribute 'indirect_branch': unknown attribute
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
   include/linux/mmzone.h:1292:15: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:113:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:125:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:126:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:110:33: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:112:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:114:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:118:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:126:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/kmemleak.h:29:33: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:29:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:30:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/pgtable.h:28:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:141:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:722:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/hrtimer.h:497:13: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/vdso.h:44:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/wait_bit.h:41:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:63:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:64:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:65:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:66:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2421:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2422:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:3329:5: sparse: attribute 'indirect_branch': unknown attribute
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
   include/linux/bootmem.h:175:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:183:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:191:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:200:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:208:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:217:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:225:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:232:22: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:240:20: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:246:20: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/bootmem.h:252:20: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/io.h:47:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/cred.h:167:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/nsproxy.h:74:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:302:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:4056:5: sparse: attribute 'indirect_branch': unknown attribute
   include/net/inetpeer.h:68:27: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/audit.h:90:12: sparse: attribute 'indirect_branch': unknown attribute
   net//ipv4/tcp.c:3577:12: sparse: attribute 'indirect_branch': unknown attribute
   net//ipv4/tcp.c:3592:13: sparse: attribute 'indirect_branch': unknown attribute
   net//ipv4/tcp.c:3602:6: sparse: attribute 'indirect_branch': unknown attribute
>> net//ipv4/tcp.c:3620:53: sparse: restricted slab_flags_t degrades to integer
>> net//ipv4/tcp.c:3620:64: sparse: incorrect type in argument 4 (different base types) @@ expected restricted slab_flags_t flags @@ got t flags @@
   net//ipv4/tcp.c:3620:64: expected restricted slab_flags_t flags
   net//ipv4/tcp.c:3620:64: got unsigned long
   include/net/sock.h:1489:31: sparse: context imbalance in 'tcp_ioctl' - unexpected unlock
   include/net/sock.h:1489:31: sparse: context imbalance in 'tcp_get_info' - unexpected unlock
--
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
   include/linux/memory_hotplug.h:221:13: sparse: attribute 'indirect_branch': unknown attribute
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
   include/linux/mmzone.h:1292:15: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:113:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:125:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/smp.h:126:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:110:33: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:112:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:114:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:118:12: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/percpu.h:126:12: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/vdso.h:44:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/kmemleak.h:29:33: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:29:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/kasan.h:30:6: sparse: attribute 'indirect_branch': unknown attribute
   arch/x86/include/asm/pgtable.h:28:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:141:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/slab.h:722:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/wait_bit.h:41:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:63:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:64:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:65:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:66:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2421:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:2422:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/fs.h:3329:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/hrtimer.h:497:13: sparse: attribute 'indirect_branch': unknown attribute
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
   include/linux/cred.h:167:13: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/nsproxy.h:74:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/io.h:47:6: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:302:5: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/netdevice.h:4056:5: sparse: attribute 'indirect_branch': unknown attribute
   include/net/inetpeer.h:68:27: sparse: attribute 'indirect_branch': unknown attribute
   include/linux/audit.h:90:12: sparse: attribute 'indirect_branch': unknown attribute
   net//ipv4/tcp_ipv4.c:2392:5: sparse: attribute 'indirect_branch': unknown attribute
   net//ipv4/tcp_ipv4.c:2578:6: sparse: attribute 'indirect_branch': unknown attribute
>> net//ipv4/tcp_ipv4.c:2437:35: sparse: restricted slab_flags_t degrades to integer
>> net//ipv4/tcp_ipv4.c:2437:56: sparse: incorrect type in initializer (different base types) @@ expected restricted slab_flags_t slab_flags @@ got t slab_flags @@
   net//ipv4/tcp_ipv4.c:2437:56: expected restricted slab_flags_t slab_flags
   net//ipv4/tcp_ipv4.c:2437:56: got unsigned long
   net//ipv4/tcp_ipv4.c:2553:50: sparse: incorrect type in assignment (different address spaces) @@ expected struct tcp_congestion_ops const @@ got ps const @@
   net//ipv4/tcp_ipv4.c:2553:50: expected struct tcp_congestion_ops const
   net//ipv4/tcp_ipv4.c:2553:50: got struct tcp_congestion_ops
   net//ipv4/tcp_ipv4.c:1572:17: sparse: context imbalance in 'tcp_add_backlog' - unexpected unlock
   net//ipv4/tcp_ipv4.c:1779:21: sparse: context imbalance in 'tcp_v4_rcv' - different lock contexts for basic block
   net//ipv4/tcp_ipv4.c:1970:20: sparse: context imbalance in 'listening_get_next' - unexpected unlock
   net//ipv4/tcp_ipv4.c:2030:9: sparse: context imbalance in 'established_get_first' - wrong count at exit
   net//ipv4/tcp_ipv4.c:2050:40: sparse: context imbalance in 'established_get_next' - unexpected unlock
   net//ipv4/tcp_ipv4.c:2178:36: sparse: context imbalance in 'tcp_seq_stop' - unexpected unlock
   net//ipv4/tcp_ipv4.c:2454:29: sparse: dereference of noderef expression
   net//ipv4/tcp_ipv4.c:2550:41: sparse: dereference of noderef expression
--
>> net//ipv6/tcp_ipv6.c:1947:35: sparse: restricted slab_flags_t degrades to integer
>> net//ipv6/tcp_ipv6.c:1947:56: sparse: incorrect type in initializer (different base types) @@ expected restricted slab_flags_t slab_flags @@ got t slab_flags @@
   net//ipv6/tcp_ipv6.c:1947:56: expected restricted slab_flags_t slab_flags
   net//ipv6/tcp_ipv6.c:1947:56: got unsigned long
   net//ipv6/tcp_ipv6.c:1551:21: sparse: context imbalance in 'tcp_v6_rcv' - different lock contexts for basic block

vim +3620 net//ipv4/tcp.c

  3575	
  3576	static __initdata unsigned long thash_entries;
> 3577	static int __init set_thash_entries(char *str)
  3578	{
  3579		ssize_t ret;
  3580	
  3581		if (!str)
  3582			return 0;
  3583	
  3584		ret = kstrtoul(str, 0, &thash_entries);
  3585		if (ret)
  3586			return 0;
  3587	
  3588		return 1;
  3589	}
  3590	__setup("thash_entries=", set_thash_entries);
  3591	
  3592	static void __init tcp_init_mem(void)
  3593	{
  3594		unsigned long limit = nr_free_buffer_pages() / 16;
  3595	
  3596		limit = max(limit, 128UL);
  3597		sysctl_tcp_mem[0] = limit / 4 * 3;		/* 4.68 % */
  3598		sysctl_tcp_mem[1] = limit;			/* 6.25 % */
  3599		sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;	/* 9.37 % */
  3600	}
  3601	
  3602	void __init tcp_init(void)
  3603	{
  3604		int max_rshare, max_wshare, cnt;
  3605		unsigned long limit;
  3606		unsigned int i;
  3607	
  3608		BUILD_BUG_ON(sizeof(struct tcp_skb_cb) >
  3609			     FIELD_SIZEOF(struct sk_buff, cb));
  3610	
  3611		percpu_counter_init(&tcp_sockets_allocated, 0, GFP_KERNEL);
  3612		percpu_counter_init(&tcp_orphan_count, 0, GFP_KERNEL);
  3613		inet_hashinfo_init(&tcp_hashinfo);
  3614		inet_hashinfo2_init(&tcp_hashinfo, "tcp_listen_portaddr_hash",
  3615				    thash_entries, 21,  /* one slot per 2 MB*/
  3616				    0, 64 * 1024);
  3617		tcp_hashinfo.bind_bucket_cachep =
  3618			kmem_cache_create("tcp_bind_bucket",
  3619					  sizeof(struct inet_bind_bucket), 0,
> 3620					  SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_VISIBLE_UAPI,

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

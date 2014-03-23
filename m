Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB046B0074
	for <linux-mm@kvack.org>; Sat, 22 Mar 2014 21:22:09 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so3906900pde.1
        for <linux-mm@kvack.org>; Sat, 22 Mar 2014 18:22:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bm8si4244220pab.302.2014.03.22.18.22.07
        for <linux-mm@kvack.org>;
        Sat, 22 Mar 2014 18:22:07 -0700 (PDT)
Date: Sun, 23 Mar 2014 09:22:03 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 450/463] drivers/firmware/efi/efi.c:315:23: sparse:
 incorrect type in argument 1 (different address spaces)
Message-ID: <532e373b.cUdwxXs3wZvqYQBo%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mark Salter <msalter@redhat.com>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   06ed26d1de59ce7cbbe68378b7e470be169750e5
commit: 840fe5e8e8d1bf37fe66c6bfe9e496c7861fae24 [450/463] x86/mm: sparse warning fix for early_memremap
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/firmware/efi/efi.c:315:23: sparse: incorrect type in argument 1 (different address spaces)
   drivers/firmware/efi/efi.c:315:23:    expected void [noderef] <asn:2>*addr
   drivers/firmware/efi/efi.c:315:23:    got void *[assigned] config_tables
--
   arch/x86/kernel/setup.c:356:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/kernel/setup.c:356:31:    expected void [noderef] <asn:2>*addr
   arch/x86/kernel/setup.c:356:31:    got char *[assigned] p
>> arch/x86/kernel/setup.c:442:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/kernel/setup.c:442:31:    expected void [noderef] <asn:2>*addr
   arch/x86/kernel/setup.c:442:31:    got struct setup_data *[assigned] data
>> arch/x86/kernel/setup.c:474:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/kernel/setup.c:474:31:    expected void [noderef] <asn:2>*addr
   arch/x86/kernel/setup.c:474:31:    got struct setup_data *[assigned] data
>> arch/x86/kernel/setup.c:495:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/kernel/setup.c:495:31:    expected void [noderef] <asn:2>*addr
   arch/x86/kernel/setup.c:495:31:    got struct setup_data *[assigned] data
--
>> arch/x86/kernel/e820.c:672:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/kernel/e820.c:672:23:    expected void [noderef] <asn:2>*addr
   arch/x86/kernel/e820.c:672:23:    got struct setup_data *[assigned] sdata
--
   arch/x86/platform/efi/efi.c:432:37: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:432:37:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:432:37:    got void *[addressable] [toplevel] [assigned] map
   arch/x86/platform/efi/efi.c:472:26: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:472:26:    expected struct efi_system_table_64_t [usertype] *systab64
   arch/x86/platform/efi/efi.c:472:26:    got void [noderef] <asn:2>*
>> arch/x86/platform/efi/efi.c:477:47: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:477:47:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:477:47:    got struct efi_setup_data *[assigned] data
   arch/x86/platform/efi/efi.c:509:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:509:31:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:509:31:    got struct efi_system_table_64_t [usertype] *systab64
>> arch/x86/platform/efi/efi.c:511:39: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:511:39:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:511:39:    got struct efi_setup_data *[assigned] data
   arch/x86/platform/efi/efi.c:521:26: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:521:26:    expected struct efi_system_table_32_t [usertype] *systab32
   arch/x86/platform/efi/efi.c:521:26:    got void [noderef] <asn:2>*
   arch/x86/platform/efi/efi.c:542:31: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:542:31:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:542:31:    got struct efi_system_table_32_t [usertype] *systab32
   arch/x86/platform/efi/efi.c:568:17: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:568:17:    expected struct efi_runtime_services_32_t [usertype] *runtime
   arch/x86/platform/efi/efi.c:568:17:    got void [noderef] <asn:2>*
   arch/x86/platform/efi/efi.c:583:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:583:23:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:583:23:    got struct efi_runtime_services_32_t [usertype] *runtime
   arch/x86/platform/efi/efi.c:592:17: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:592:17:    expected struct efi_runtime_services_64_t [usertype] *runtime
   arch/x86/platform/efi/efi.c:592:17:    got void [noderef] <asn:2>*
   arch/x86/platform/efi/efi.c:607:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:607:23:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:607:23:    got struct efi_runtime_services_64_t [usertype] *runtime
   arch/x86/platform/efi/efi.c:638:20: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:638:20:    expected void *[addressable] [toplevel] [assigned] map
   arch/x86/platform/efi/efi.c:638:20:    got void [noderef] <asn:2>*
>> arch/x86/platform/efi/efi.c:702:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:702:23:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:702:23:    got void *[assigned] tablep
>> arch/x86/platform/efi/efi.c:705:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:705:23:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:705:23:    got struct efi_setup_data *[assigned] data
   arch/x86/platform/efi/efi.c:742:19: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:742:19:    expected void *tmp
   arch/x86/platform/efi/efi.c:742:19:    got void [noderef] <asn:2>*
   arch/x86/platform/efi/efi.c:749:23: sparse: incorrect type in argument 1 (different address spaces)
   arch/x86/platform/efi/efi.c:749:23:    expected void [noderef] <asn:2>*addr
   arch/x86/platform/efi/efi.c:749:23:    got void *tmp
   arch/x86/platform/efi/efi.c:843:20: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi.c:843:20:    expected void *[assigned] va
   arch/x86/platform/efi/efi.c:843:20:    got void [noderef] <asn:2>*
--
>> arch/x86/platform/efi/efi-bgrt.c:52:23: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi-bgrt.c:52:23:    expected void [noderef] <asn:2>*[assigned] image
   arch/x86/platform/efi/efi-bgrt.c:52:23:    got void *
>> arch/x86/platform/efi/efi-bgrt.c:69:23: sparse: incorrect type in assignment (different address spaces)
   arch/x86/platform/efi/efi-bgrt.c:69:23:    expected void [noderef] <asn:2>*[assigned] image
   arch/x86/platform/efi/efi-bgrt.c:69:23:    got void *

vim +315 drivers/firmware/efi/efi.c

272686bf Leif Lindholm 2013-09-05  299  				early_iounmap(config_tables,
272686bf Leif Lindholm 2013-09-05  300  					       efi.systab->nr_tables * sz);
272686bf Leif Lindholm 2013-09-05  301  				return -EINVAL;
272686bf Leif Lindholm 2013-09-05  302  			}
272686bf Leif Lindholm 2013-09-05  303  #endif
272686bf Leif Lindholm 2013-09-05  304  		} else {
272686bf Leif Lindholm 2013-09-05  305  			guid = ((efi_config_table_32_t *)tablep)->guid;
272686bf Leif Lindholm 2013-09-05  306  			table = ((efi_config_table_32_t *)tablep)->table;
272686bf Leif Lindholm 2013-09-05  307  		}
272686bf Leif Lindholm 2013-09-05  308  
272686bf Leif Lindholm 2013-09-05  309  		if (!match_config_table(&guid, table, common_tables))
272686bf Leif Lindholm 2013-09-05  310  			match_config_table(&guid, table, arch_tables);
272686bf Leif Lindholm 2013-09-05  311  
272686bf Leif Lindholm 2013-09-05  312  		tablep += sz;
272686bf Leif Lindholm 2013-09-05  313  	}
272686bf Leif Lindholm 2013-09-05  314  	pr_cont("\n");
272686bf Leif Lindholm 2013-09-05 @315  	early_iounmap(config_tables, efi.systab->nr_tables * sz);
0f8093a9 Matt Fleming  2014-01-15  316  
0f8093a9 Matt Fleming  2014-01-15  317  	set_bit(EFI_CONFIG_TABLES, &efi.flags);
0f8093a9 Matt Fleming  2014-01-15  318  
272686bf Leif Lindholm 2013-09-05  319  	return 0;
272686bf Leif Lindholm 2013-09-05  320  }

:::::: The code at line 315 was first introduced by commit
:::::: 272686bf46a34f86d270cf192f68769667792026 efi: x86: ia64: provide a generic efi_config_init()

:::::: TO: Leif Lindholm <leif.lindholm@linaro.org>
:::::: CC: Matt Fleming <matt.fleming@intel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

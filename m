Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75D326B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:44:09 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so33931209lfa.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 04:44:09 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id w63si1109216wmw.47.2016.06.29.04.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 04:44:08 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id a66so13625306wme.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 04:44:07 -0700 (PDT)
Date: Wed, 29 Jun 2016 14:44:05 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [linux-next:master 11901/11991] mm/huge_memory.c:604:16: error:
 invalid storage class for function 'khugepaged_max_ptes_swap_show'
Message-ID: <20160629114405.GA7218@gmail.com>
References: <201605241951.WLO3Ag8c%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605241951.WLO3Ag8c%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, May 24, 2016 at 07:39:53PM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   66c198deda3725c57939c6cdaf2c9f5375cd79ad
> commit: ca9c8b6c0b78b9d5b1e6569f02b25f852a99d444 [11901/11991] mm: make optimistic check for swapin readahead
> config: i386-randconfig-h1-05241552 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout ca9c8b6c0b78b9d5b1e6569f02b25f852a99d444
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
I've checked out ca9c8b6c0b78b9d5b1e6 and using the same config
I couldn't reproduce this bug.

I checked mm-make-optimistic-check-for-swapin-readahead.patch
however could not see my mistake.

Here is what get when compiled: http://pastebin.com/S36r7Fwh
I am getting "invalid storage class" error for other functions.


According the following result, I saw that the same bug occured
for some sysfs knobs as well.

I read the bug can be due to missing paranthesis however I can't
see the missed. I guess that I have to use static functions for
the syfs knob.

Can you correct me if I am wrong?
 
> All errors (new ones prefixed by >>):
> 
>                ^
>    include/linux/sysfs.h:116:10: note: in definition of macro '__ATTR_RO'
>      .show = _name##_show,      \
>              ^~~~~
>    mm/huge_memory.c:543:12: note: (near initialization for 'pages_collapsed_attr.show')
>      __ATTR_RO(pages_collapsed);
>                ^
>    include/linux/sysfs.h:116:10: note: in definition of macro '__ATTR_RO'
>      .show = _name##_show,      \
>              ^~~~~
>    mm/huge_memory.c:545:16: error: invalid storage class for function 'full_scans_show'
>     static ssize_t full_scans_show(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~
>    In file included from include/linux/kobject.h:21:0,
>                     from include/linux/device.h:17,
>                     from include/linux/node.h:17,
>                     from include/linux/swap.h:10,
>                     from mm/huge_memory.c:16:
>    mm/huge_memory.c:552:12: error: initializer element is not constant
>      __ATTR_RO(full_scans);
>                ^
>    include/linux/sysfs.h:116:10: note: in definition of macro '__ATTR_RO'
>      .show = _name##_show,      \
>              ^~~~~
>    mm/huge_memory.c:552:12: note: (near initialization for 'full_scans_attr.show')
>      __ATTR_RO(full_scans);
>                ^
>    include/linux/sysfs.h:116:10: note: in definition of macro '__ATTR_RO'
>      .show = _name##_show,      \
>              ^~~~~
>    mm/huge_memory.c:554:16: error: invalid storage class for function 'khugepaged_defrag_show'
>     static ssize_t khugepaged_defrag_show(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:560:16: error: invalid storage class for function 'khugepaged_defrag_store'
>     static ssize_t khugepaged_defrag_store(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~~
>    In file included from include/linux/kobject.h:21:0,
>                     from include/linux/device.h:17,
>                     from include/linux/node.h:17,
>                     from include/linux/swap.h:10,
>                     from mm/huge_memory.c:16:
>    mm/huge_memory.c:568:23: error: initializer element is not constant
>      __ATTR(defrag, 0644, khugepaged_defrag_show,
>                           ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:568:23: note: (near initialization for 'khugepaged_defrag_attr.show')
>      __ATTR(defrag, 0644, khugepaged_defrag_show,
>                           ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:569:9: error: initializer element is not constant
>             khugepaged_defrag_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
>    mm/huge_memory.c:569:9: note: (near initialization for 'khugepaged_defrag_attr.store')
>             khugepaged_defrag_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
>    mm/huge_memory.c:579:16: error: invalid storage class for function 'khugepaged_max_ptes_none_show'
>     static ssize_t khugepaged_max_ptes_none_show(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:585:16: error: invalid storage class for function 'khugepaged_max_ptes_none_store'
>     static ssize_t khugepaged_max_ptes_none_store(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    In file included from include/linux/kobject.h:21:0,
>                     from include/linux/device.h:17,
>                     from include/linux/node.h:17,
>                     from include/linux/swap.h:10,
>                     from mm/huge_memory.c:16:
>    mm/huge_memory.c:601:30: error: initializer element is not constant
>      __ATTR(max_ptes_none, 0644, khugepaged_max_ptes_none_show,
>                                  ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:601:30: note: (near initialization for 'khugepaged_max_ptes_none_attr.show')
>      __ATTR(max_ptes_none, 0644, khugepaged_max_ptes_none_show,
>                                  ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:602:9: error: initializer element is not constant
>             khugepaged_max_ptes_none_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
>    mm/huge_memory.c:602:9: note: (near initialization for 'khugepaged_max_ptes_none_attr.store')
>             khugepaged_max_ptes_none_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
> >> mm/huge_memory.c:604:16: error: invalid storage class for function 'khugepaged_max_ptes_swap_show'
>     static ssize_t khugepaged_max_ptes_swap_show(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >> mm/huge_memory.c:611:16: error: invalid storage class for function 'khugepaged_max_ptes_swap_store'
>     static ssize_t khugepaged_max_ptes_swap_store(struct kobject *kobj,
>                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    In file included from include/linux/kobject.h:21:0,
>                     from include/linux/device.h:17,
>                     from include/linux/node.h:17,
>                     from include/linux/swap.h:10,
>                     from mm/huge_memory.c:16:
>    mm/huge_memory.c:628:30: error: initializer element is not constant
>      __ATTR(max_ptes_swap, 0644, khugepaged_max_ptes_swap_show,
>                                  ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:628:30: note: (near initialization for 'khugepaged_max_ptes_swap_attr.show')
>      __ATTR(max_ptes_swap, 0644, khugepaged_max_ptes_swap_show,
>                                  ^
>    include/linux/sysfs.h:103:10: note: in definition of macro '__ATTR'
>      .show = _show,      \
>              ^~~~~
>    mm/huge_memory.c:629:9: error: initializer element is not constant
>             khugepaged_max_ptes_swap_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
>    mm/huge_memory.c:629:9: note: (near initialization for 'khugepaged_max_ptes_swap_attr.store')
>             khugepaged_max_ptes_swap_store);
>             ^
>    include/linux/sysfs.h:104:11: note: in definition of macro '__ATTR'
>      .store = _store,      \
>               ^~~~~~
>    mm/huge_memory.c:643:15: error: variable 'khugepaged_attr_group' has initializer but incomplete type
>     static struct attribute_group khugepaged_attr_group = {
>                   ^~~~~~~~~~~~~~~
>    mm/huge_memory.c:644:2: error: unknown field 'attrs' specified in initializer
>      .attrs = khugepaged_attr,
>      ^
>    mm/huge_memory.c:644:11: warning: excess elements in struct initializer
>      .attrs = khugepaged_attr,
>               ^~~~~~~~~~~~~~~
>    mm/huge_memory.c:644:11: note: (near initialization for 'khugepaged_attr_group')
>    mm/huge_memory.c:645:2: error: unknown field 'name' specified in initializer
>      .name = "khugepaged",
>      ^
>    mm/huge_memory.c:645:10: warning: excess elements in struct initializer
>      .name = "khugepaged",
>              ^~~~~~~~~~~~
>    mm/huge_memory.c:645:10: note: (near initialization for 'khugepaged_attr_group')
>    mm/huge_memory.c:643:31: error: storage size of 'khugepaged_attr_group' isn't known
>     static struct attribute_group khugepaged_attr_group = {
>                                   ^~~~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:648:19: error: invalid storage class for function 'hugepage_init_sysfs'
>     static int __init hugepage_init_sysfs(struct kobject **hugepage_kobj)
>                       ^~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:679:20: error: invalid storage class for function 'hugepage_exit_sysfs'
>     static void __init hugepage_exit_sysfs(struct kobject *hugepage_kobj)
>                        ^~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:696:19: error: invalid storage class for function 'hugepage_init'
>     static int __init hugepage_init(void)
>                       ^~~~~~~~~~~~~
>    mm/huge_memory.c: In function 'hugepage_init':
>    mm/huge_memory.c:722:8: error: implicit declaration of function 'khugepaged_slab_init' [-Werror=implicit-function-declaration]
>      err = khugepaged_slab_init();
>            ^~~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:753:2: error: implicit declaration of function 'khugepaged_slab_exit' [-Werror=implicit-function-declaration]
>      khugepaged_slab_exit();
>      ^~~~~~~~~~~~~~~~~~~~
>    In file included from include/linux/printk.h:5:0,
>                     from include/linux/kernel.h:13,
>                     from include/asm-generic/bug.h:13,
>                     from arch/x86/include/asm/bug.h:35,
>                     from include/linux/bug.h:4,
>                     from include/linux/mmdebug.h:4,
>                     from include/linux/mm.h:8,
>                     from mm/huge_memory.c:10:
>    mm/huge_memory.c: In function 'page_is_young':
>    mm/huge_memory.c:759:17: error: initializer element is not constant
>     subsys_initcall(hugepage_init);
>                     ^
>    include/linux/init.h:188:58: note: in definition of macro '__define_initcall'
>      __attribute__((__section__(".initcall" #id ".init"))) = fn; \
>                                                              ^~
>    mm/huge_memory.c:759:1: note: in expansion of macro 'subsys_initcall'
>     subsys_initcall(hugepage_init);
>     ^~~~~~~~~~~~~~~
>    mm/huge_memory.c:761:19: error: invalid storage class for function 'setup_transparent_hugepage'
>     static int __init setup_transparent_hugepage(char *str)
>                       ^~~~~~~~~~~~~~~~~~~~~~~~~~
>    mm/huge_memory.c:761:1: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
>     static int __init setup_transparent_hugepage(char *str)
>     ^~~~~~
>    In file included from include/linux/printk.h:5:0,
>                     from include/linux/kernel.h:13,
>                     from include/asm-generic/bug.h:13,
>                     from arch/x86/include/asm/bug.h:35,
>                     from include/linux/bug.h:4,
>                     from include/linux/mmdebug.h:4,
>                     from include/linux/mm.h:8,
>                     from mm/huge_memory.c:10:
>    mm/huge_memory.c:790:34: error: initializer element is not constant
> 
> vim +/khugepaged_max_ptes_swap_show +604 mm/huge_memory.c
> 
>    596		khugepaged_max_ptes_none = max_ptes_none;
>    597	
>    598		return count;
>    599	}
>    600	static struct kobj_attribute khugepaged_max_ptes_none_attr =
>    601		__ATTR(max_ptes_none, 0644, khugepaged_max_ptes_none_show,
>  > 602		       khugepaged_max_ptes_none_store);
>    603	
>  > 604	static ssize_t khugepaged_max_ptes_swap_show(struct kobject *kobj,
>    605						     struct kobj_attribute *attr,
>    606						     char *buf)
>    607	{
>    608		return sprintf(buf, "%u\n", khugepaged_max_ptes_swap);
>    609	}
>    610	
>  > 611	static ssize_t khugepaged_max_ptes_swap_store(struct kobject *kobj,
>    612						      struct kobj_attribute *attr,
>    613						      const char *buf, size_t count)
>    614	{
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08CF96B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 08:25:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so396547827pfg.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:25:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id m89si14438949pfk.254.2016.07.25.05.25.09
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 05:25:09 -0700 (PDT)
Date: Mon, 25 Jul 2016 20:24:42 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 12118/12164]
 arch/x86/include/asm/dma-mapping.h:12:29: fatal error: linux/dma-attrs.h: No
 such file or directory
Message-ID: <201607252039.nncm7Vim%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   f7d63d99206b9ea674b6869f01ab68d651c717a2
commit: f48c41eedd53dd90c5fc37744932c806ece58b74 [12118/12164] dma-mapping: use unsigned long for dma_attrs
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        git checkout f48c41eedd53dd90c5fc37744932c806ece58b74
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-next/master HEAD f7d63d99206b9ea674b6869f01ab68d651c717a2 builds fine.
      It may have been fixed somewhere.

All errors (new ones prefixed by >>):

   In file included from include/linux/dma-mapping.h:132:0,
                    from include/linux/skbuff.h:34,
                    from include/linux/icmpv6.h:4,
                    from include/linux/ipv6.h:75,
                    from include/net/ipv6.h:16,
                    from include/linux/sunrpc/clnt.h:27,
                    from include/linux/nfs_fs.h:30,
                    from init/do_mounts.c:32:
>> arch/x86/include/asm/dma-mapping.h:12:29: fatal error: linux/dma-attrs.h: No such file or directory
    #include <linux/dma-attrs.h>
                                ^
   compilation terminated.

vim +12 arch/x86/include/asm/dma-mapping.h

5872fb94 arch/x86/include/asm/dma-mapping.h Randy Dunlap     2009-01-29   6   * Documentation/DMA-API.txt for documentation.
6f536635 include/asm-x86/dma-mapping.h      Glauber Costa    2008-03-25   7   */
6f536635 include/asm-x86/dma-mapping.h      Glauber Costa    2008-03-25   8  
d7002857 arch/x86/include/asm/dma-mapping.h Vegard Nossum    2008-07-20   9  #include <linux/kmemcheck.h>
6f536635 include/asm-x86/dma-mapping.h      Glauber Costa    2008-03-25  10  #include <linux/scatterlist.h>
2118d0c5 arch/x86/include/asm/dma-mapping.h Joerg Roedel     2009-01-09  11  #include <linux/dma-debug.h>
abe6602b arch/x86/include/asm/dma-mapping.h FUJITA Tomonori  2009-01-05 @12  #include <linux/dma-attrs.h>
6f536635 include/asm-x86/dma-mapping.h      Glauber Costa    2008-03-25  13  #include <asm/io.h>
6f536635 include/asm-x86/dma-mapping.h      Glauber Costa    2008-03-25  14  #include <asm/swiotlb.h>
0a2b9a6e arch/x86/include/asm/dma-mapping.h Marek Szyprowski 2011-12-29  15  #include <linux/dma-contiguous.h>

:::::: The code at line 12 was first introduced by commit
:::::: abe6602bf197167efb3b37161b9c11748fa076e1 x86: add map_page and unmap_page to struct dma_mapping_ops

:::::: TO: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
:::::: CC: Ingo Molnar <mingo@elte.hu>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--PNTmBPCT7hxwcZjr
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
rloAAA==

--PNTmBPCT7hxwcZjr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

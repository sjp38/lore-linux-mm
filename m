Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 502376B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:40:45 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so61307662pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:40:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rt3si7957116pbb.88.2015.11.18.16.40.44
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 16:40:44 -0800 (PST)
Date: Thu, 19 Nov 2015 08:39:32 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511181629220.1381@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

[auto build test ERROR on: next-20151118]
[also build test ERROR on: v4.4-rc1]

url:    https://github.com/0day-ci/linux/commits/David-Rientjes/mm-vmalloc-remove-VM_VPAGES/20151119-083326
config: i386-tinyconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/vmalloc.c: In function '__vunmap':
>> mm/vmalloc.c:1484:21: error: 'VM_VPAGES' undeclared (first use in this function)
      if (area->flags & VM_VPAGES)
                        ^
   mm/vmalloc.c:1484:21: note: each undeclared identifier is reported only once for each function it appears in

vim +/VM_VPAGES +1484 mm/vmalloc.c

bf53d6f8 Christoph Lameter 2008-02-04  1478  			struct page *page = area->pages[i];
bf53d6f8 Christoph Lameter 2008-02-04  1479  
bf53d6f8 Christoph Lameter 2008-02-04  1480  			BUG_ON(!page);
bf53d6f8 Christoph Lameter 2008-02-04  1481  			__free_page(page);
^1da177e Linus Torvalds    2005-04-16  1482  		}
^1da177e Linus Torvalds    2005-04-16  1483  
8757d5fa Jan Kiszka        2006-07-14 @1484  		if (area->flags & VM_VPAGES)
^1da177e Linus Torvalds    2005-04-16  1485  			vfree(area->pages);
^1da177e Linus Torvalds    2005-04-16  1486  		else
^1da177e Linus Torvalds    2005-04-16  1487  			kfree(area->pages);

:::::: The code at line 1484 was first introduced by commit
:::::: 8757d5fa6b75e8ea906baf0309d49b980e7f9bc9 [PATCH] mm: fix oom roll-back of __vmalloc_area_node

:::::: TO: Jan Kiszka <jan.kiszka@web.de>
:::::: CC: Linus Torvalds <torvalds@g5.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--oyUTqETQ0mS9luUI
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
KgSftfK8suFVAAA=

--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

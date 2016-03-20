Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 933546B0262
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:54:52 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id x3so231140486pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:54:52 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id h78si14750995pfh.148.2016.03.20.05.54.51
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 05:54:51 -0700 (PDT)
Date: Sun, 20 Mar 2016 20:53:28 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/5] uffd: Add fork() event
Message-ID: <201603202029.DGStOszG%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Content-Disposition: inline
In-Reply-To: <1458477741-6942-4-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rapoport@il.ibm.com>
Cc: kbuild-all@01.org, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Pavel,

[auto build test ERROR on next-20160318]
[also build test ERROR on v4.5]
[cannot apply to v4.5-rc7 v4.5-rc6 v4.5-rc5]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Mike-Rapoport/userfaultfd-extension-for-non-cooperative-uffd-usage/20160320-204520
config: i386-tinyconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from kernel/fork.c:58:0:
   include/linux/userfaultfd_k.h: In function 'dup_userfaultfd':
>> include/linux/userfaultfd_k.h:86:42: error: parameter name omitted
    static inline int dup_userfaultfd(struct vm_area_struct *, struct list_head *)
                                             ^
   include/linux/userfaultfd_k.h:86:67: error: parameter name omitted
    static inline int dup_userfaultfd(struct vm_area_struct *, struct list_head *)
                                                                      ^
   include/linux/userfaultfd_k.h: In function 'dup_userfaultfd_complete':
   include/linux/userfaultfd_k.h:91:52: error: parameter name omitted
    static inline void dup_userfaultfd_complete(struct list_head *)
                                                       ^

vim +86 include/linux/userfaultfd_k.h

    80	
    81	static inline bool userfaultfd_armed(struct vm_area_struct *vma)
    82	{
    83		return false;
    84	}
    85	
  > 86	static inline int dup_userfaultfd(struct vm_area_struct *, struct list_head *)
    87	{
    88		return 0;
    89	}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--CE+1k2dSO48ffgeK
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--CE+1k2dSO48ffgeK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

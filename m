Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 43D266B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:29:10 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vp2so36669390pab.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 07:29:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v64si4788358pfj.110.2016.09.07.07.29.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 07:29:09 -0700 (PDT)
Date: Wed, 7 Sep 2016 22:28:56 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] ipc/shm: fix crash if CONFIG_SHMEM is not set
Message-ID: <201609072221.M7OSrgbL%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Content-Disposition: inline
In-Reply-To: <20160907111452.GA138665@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: kbuild-all@01.org, Tony Battersby <tonyb@cybernetics.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kirill,

[auto build test ERROR on linus/master]
[also build test ERROR on v4.8-rc5 next-20160907]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/ipc-shm-fix-crash-if-CONFIG_SHMEM-is-not-set/20160907-204216
config: sh-rsk7201_defconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sh 

All errors (new ones prefixed by >>):

   ipc/shm.c: In function 'shm_get_unmapped_area':
>> ipc/shm.c:477:25: error: 'struct mm_struct' has no member named 'get_unmapped_area'
      get_area = current->mm->get_unmapped_area;
                            ^

vim +477 ipc/shm.c

   471				unsigned long, unsigned long);
   472		struct shm_file_data *sfd = shm_file_data(file);
   473	
   474		if (sfd->file->f_op->get_unmapped_area)
   475			get_area = sfd->file->f_op->get_unmapped_area;
   476		else
 > 477			get_area = current->mm->get_unmapped_area;
   478		return get_area(sfd->file, addr, len, pgoff, flags);
   479	}
   480	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--7AUc2qLy4jB3hD7Z
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
+N6NZ1ps/gedlNgJt28AAA==

--7AUc2qLy4jB3hD7Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

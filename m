Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD83831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 13:08:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p86so135249960pfl.12
        for <linux-mm@kvack.org>; Mon, 22 May 2017 10:08:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 33si18446508plb.270.2017.05.22.10.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 10:08:33 -0700 (PDT)
Date: Tue, 23 May 2017 01:07:15 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] Patch for remapping pages around the fault page
Message-ID: <201705230125.i1Cthtdz%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <1495379520-23752-1-git-send-email-sarunya@vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarunya Pumma <sarunya@vt.edu>
Cc: kbuild-all@01.org, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sarunya,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.12-rc2 next-20170522]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Sarunya-Pumma/Patch-for-remapping-pages-around-the-fault-page/20170522-211816
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

>> kernel/built-in.o:(.fardata+0x1b2c): undefined reference to `vm_nr_remapping'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Unw2jSXwNAJGDsLpm5vxI7T9P7VQr7EsSgAA

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

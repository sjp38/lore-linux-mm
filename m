Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 50A1E82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:44:22 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id q3so99647399pav.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:44:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xk9si5533577pab.38.2015.12.22.09.44.21
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 09:44:21 -0800 (PST)
Date: Wed, 23 Dec 2015 01:43:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 6909/7874] undefined reference to `early_panic'
Message-ID: <201512230154.Qb1INcNC%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   3248efff60b83f93dad704e98d80657285aa0780
commit: bbbfaae3a26dd9762187f0daac74889661a4f0dd [6909/7874] mm-oom-introduce-oom-reaper-fix-fix-2
config: tile-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout bbbfaae3a26dd9762187f0daac74889661a4f0dd
        # save the attached .config to linux build tree
        make.cross ARCH=tile 

All errors (new ones prefixed by >>):

   arch/tile/built-in.o: In function `setup_arch':
>> (.init.text+0x15d8): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1610): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1800): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1828): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1bd8): undefined reference to `early_panic'
   arch/tile/built-in.o:(.init.text+0x1c18): more undefined references to `early_panic' follow

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--Nq2Wo0NMKNjxTN9z
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--Nq2Wo0NMKNjxTN9z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

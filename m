Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B66A46B0260
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:16:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ap1so4799850pad.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:16:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s202si12353365pfs.76.2016.04.19.09.16.22
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 09:16:22 -0700 (PDT)
Date: Wed, 20 Apr 2016 00:14:28 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <201604200014.yGwUyG4n%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: kbuild-all@01.org, mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on v4.6-rc4]
[also build test ERROR on next-20160419]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Liang-Li/speed-up-live-migration-by-skipping-free-pages/20160419-224707
config: parisc-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=parisc 

All errors (new ones prefixed by >>):

   mm/built-in.o: In function `get_free_pages':
>> (.text.get_free_pages+0x28): undefined reference to `drop_cache'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BOKacYhQ+x31HxR3
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
07ZRmj773cqM65aVLc/xX3L91sqYPAAA

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

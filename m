Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB916B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:01:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t124so36711298pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:01:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x1si14696734pfb.185.2016.04.19.09.01.48
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 09:01:48 -0700 (PDT)
Date: Wed, 20 Apr 2016 00:01:08 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Message-ID: <201604200003.mbi2rLmF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: kbuild-all@01.org, mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on v4.6-rc4]
[also build test ERROR on next-20160419]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Liang-Li/speed-up-live-migration-by-skipping-free-pages/20160419-224707
config: arm-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   mm/built-in.o: In function `get_free_pages':
>> :(.text+0x3db4): undefined reference to `drop_cache'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B517D6B007E
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 20:11:07 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so117149877pab.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 17:11:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 69si30752268pfk.13.2016.04.02.17.11.06
        for <linux-mm@kvack.org>;
        Sat, 02 Apr 2016 17:11:06 -0700 (PDT)
Date: Sun, 3 Apr 2016 08:09:32 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: {standard input}:116: Error: number (0x9000000080000000) larger than
 32 bits
Message-ID: <201604030828.zhpYDc36%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sasha,

FYI, the error/warning still remains.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   264800b5ecc7be49b2c6027738091ff3385e0cae
commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
date:   1 year, 6 months ago
config: mips-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 71458cfc782eafe4b27656e078d379a34e472adf
        # save the attached .config to linux build tree
        make.cross ARCH=mips 

All errors (new ones prefixed by >>):

   {standard input}: Assembler messages:
>> {standard input}:116: Error: number (0x9000000080000000) larger than 32 bits
   {standard input}:150: Error: number (0x9000000080000000) larger than 32 bits
   {standard input}:172: Error: number (0x9000000080000000) larger than 32 bits

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--9amGYk9869ThD9tj
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Pgx+/v9/sbNFCE9BAAA=

--9amGYk9869ThD9tj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

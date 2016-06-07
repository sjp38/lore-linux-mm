Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6686B0260
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:14:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so271637545pfs.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:14:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ss2si32216688pab.111.2016.06.07.02.14.12
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 02:14:12 -0700 (PDT)
Date: Tue, 7 Jun 2016 17:17:49 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: tile: early_printk.o is always required
Message-ID: <201606071706.sPPjN9gM%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="qDbXVdCdHGoSgWSk"
Content-Disposition: inline
In-Reply-To: <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Chris Metcalf <cmetcalf@mellanox.com>


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on tile/master]
[also build test ERROR on v4.7-rc2 next-20160606]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Andrew-Morton/tile-early_printk-o-is-always-required/20160607-043356
base:   https://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git master
config: tile-allnoconfig (attached as .config)
compiler: tilegx-linux-gcc (GCC) 4.6.2
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=tile 

All errors (new ones prefixed by >>):

   arch/tile/built-in.o: In function `early_hv_write':
>> early_printk.c:(.text+0xc770): undefined reference to `tile_console_write'
   early_printk.c:(.text+0xc800): undefined reference to `tile_console_write'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--qDbXVdCdHGoSgWSk
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--qDbXVdCdHGoSgWSk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id DA38B6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 04:35:12 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so6851403pbc.13
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 01:35:12 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r7si19816694pbk.357.2014.02.03.01.35.11
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 01:35:11 -0800 (PST)
Date: Mon, 03 Feb 2014 17:35:08 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: drivers/mfd/tc3589x.c:324: warning: 'child' is used uninitialized in this function
Message-ID: <52ef62cc.PW03fery3VxkG0UF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   38dbfb59d1175ef458d006556061adeaa8751b72
commit: 00b2c76a6abbe082bb5afb89ee49ec325e9cd4d2 include/linux/of.h: make for_each_child_of_node() reference its args when CONFIG_OF=n
date:   10 days ago
config: make ARCH=avr32 allyesconfig

All warnings:

   drivers/mfd/tc3589x.c: In function 'tc3589x_probe':
>> drivers/mfd/tc3589x.c:324: warning: 'child' is used uninitialized in this function
   drivers/mfd/tc3589x.c:324: note: 'child' was declared here
--
   drivers/mfd/stmpe.c: In function 'stmpe_of_probe':
>> drivers/mfd/stmpe.c:1112: warning: 'child' is used uninitialized in this function

vim +/child +324 drivers/mfd/tc3589x.c

09c730a4 Sundar Iyer 2010-12-21  308  		ret = mfd_add_devices(tc3589x->dev, -1, tc3589x_dev_keypad,
55692af5 Mark Brown  2012-09-11  309  				      ARRAY_SIZE(tc3589x_dev_keypad), NULL,
15e27b10 Lee Jones   2012-09-07  310  				      tc3589x->irq_base, tc3589x->domain);
09c730a4 Sundar Iyer 2010-12-21  311  		if (ret) {
09c730a4 Sundar Iyer 2010-12-21  312  			dev_err(tc3589x->dev, "failed to keypad child\n");
09c730a4 Sundar Iyer 2010-12-21  313  			return ret;
09c730a4 Sundar Iyer 2010-12-21  314  		}
09c730a4 Sundar Iyer 2010-12-21  315  		dev_info(tc3589x->dev, "added keypad block\n");
09c730a4 Sundar Iyer 2010-12-21  316  	}
611b7590 Sundar Iyer 2010-12-13  317  
09c730a4 Sundar Iyer 2010-12-21  318  	return ret;
611b7590 Sundar Iyer 2010-12-13  319  }
611b7590 Sundar Iyer 2010-12-13  320  
a435ae1d Lee Jones   2012-09-07  321  static int tc3589x_of_probe(struct device_node *np,
a435ae1d Lee Jones   2012-09-07  322  			struct tc3589x_platform_data *pdata)
a435ae1d Lee Jones   2012-09-07  323  {
a435ae1d Lee Jones   2012-09-07 @324  	struct device_node *child;
a435ae1d Lee Jones   2012-09-07  325  
a435ae1d Lee Jones   2012-09-07  326  	for_each_child_of_node(np, child) {
a435ae1d Lee Jones   2012-09-07  327  		if (!strcmp(child->name, "tc3589x_gpio")) {
a435ae1d Lee Jones   2012-09-07  328  			pdata->block |= TC3589x_BLOCK_GPIO;
a435ae1d Lee Jones   2012-09-07  329  		}
a435ae1d Lee Jones   2012-09-07  330  		if (!strcmp(child->name, "tc3589x_keypad")) {
a435ae1d Lee Jones   2012-09-07  331  			pdata->block |= TC3589x_BLOCK_KEYPAD;
a435ae1d Lee Jones   2012-09-07  332  		}

:::::: The code at line 324 was first introduced by commit
:::::: a435ae1d51e2f18414f2a87219fdbe068231e692 mfd: Enable the tc3589x for Device Tree

:::::: TO: Lee Jones <lee.jones@linaro.org>
:::::: CC: Samuel Ortiz <sameo@linux.intel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

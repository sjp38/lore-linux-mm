Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 758556B0255
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 11:43:23 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so8765555obb.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 08:43:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id cw3si11849521oec.8.2015.09.29.08.43.22
        for <linux-mm@kvack.org>;
        Tue, 29 Sep 2015 08:43:22 -0700 (PDT)
Date: Tue, 29 Sep 2015 23:42:29 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: drivers/hid/i2c-hid/i2c-hid.c:1134:3-8: No need to set .owner here.
 The core will do it.
Message-ID: <201509292326.febSgyj7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Sasha,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   097f70b3c4d84ffccca15195bdfde3a37c0a7c0f
commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
date:   12 months ago


coccinelle warnings: (new ones prefixed by >>)

>> drivers/hid/i2c-hid/i2c-hid.c:1134:3-8: No need to set .owner here. The core will do it.

vim +1134 drivers/hid/i2c-hid/i2c-hid.c

34f439e4 Mika Westerberg    2014-01-29  1118  static const struct dev_pm_ops i2c_hid_pm = {
34f439e4 Mika Westerberg    2014-01-29  1119  	SET_SYSTEM_SLEEP_PM_OPS(i2c_hid_suspend, i2c_hid_resume)
34f439e4 Mika Westerberg    2014-01-29  1120  	SET_RUNTIME_PM_OPS(i2c_hid_runtime_suspend, i2c_hid_runtime_resume,
34f439e4 Mika Westerberg    2014-01-29  1121  			   NULL)
34f439e4 Mika Westerberg    2014-01-29  1122  };
4a200c3b Benjamin Tissoires 2012-11-12  1123  
4a200c3b Benjamin Tissoires 2012-11-12  1124  static const struct i2c_device_id i2c_hid_id_table[] = {
24ebb37e Benjamin Tissoires 2012-12-04  1125  	{ "hid", 0 },
4a200c3b Benjamin Tissoires 2012-11-12  1126  	{ },
4a200c3b Benjamin Tissoires 2012-11-12  1127  };
4a200c3b Benjamin Tissoires 2012-11-12  1128  MODULE_DEVICE_TABLE(i2c, i2c_hid_id_table);
4a200c3b Benjamin Tissoires 2012-11-12  1129  
4a200c3b Benjamin Tissoires 2012-11-12  1130  
4a200c3b Benjamin Tissoires 2012-11-12  1131  static struct i2c_driver i2c_hid_driver = {
4a200c3b Benjamin Tissoires 2012-11-12  1132  	.driver = {
4a200c3b Benjamin Tissoires 2012-11-12  1133  		.name	= "i2c_hid",
4a200c3b Benjamin Tissoires 2012-11-12 @1134  		.owner	= THIS_MODULE,
4a200c3b Benjamin Tissoires 2012-11-12  1135  		.pm	= &i2c_hid_pm,
92241e67 Mika Westerberg    2013-01-09  1136  		.acpi_match_table = ACPI_PTR(i2c_hid_acpi_match),
3d7d248c Benjamin Tissoires 2013-06-13  1137  		.of_match_table = of_match_ptr(i2c_hid_of_match),
4a200c3b Benjamin Tissoires 2012-11-12  1138  	},
4a200c3b Benjamin Tissoires 2012-11-12  1139  
4a200c3b Benjamin Tissoires 2012-11-12  1140  	.probe		= i2c_hid_probe,
0fe763c5 Greg Kroah-Hartman 2012-12-21  1141  	.remove		= i2c_hid_remove,
4a200c3b Benjamin Tissoires 2012-11-12  1142  

:::::: The code at line 1134 was first introduced by commit
:::::: 4a200c3b9a40242652b5734630bdd0bcf3aca75f HID: i2c-hid: introduce HID over i2c specification implementation

:::::: TO: Benjamin Tissoires <benjamin.tissoires@gmail.com>
:::::: CC: Jiri Kosina <jkosina@suse.cz>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

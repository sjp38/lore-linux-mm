Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF556B0032
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 13:16:49 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so10138240pdb.3
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 10:16:49 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ta5si5788574pbc.38.2015.03.01.10.16.48
        for <linux-mm@kvack.org>;
        Sun, 01 Mar 2015 10:16:48 -0800 (PST)
Date: Mon, 2 Mar 2015 02:16:08 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: drivers/rtc/rtc-ds1685.c:2144:3-8: No need to set .owner here. The
 core will do it.
Message-ID: <201503020206.bGFVliQR%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Kinard <kumba@gentoo.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   ae1aa797e0ace9bbce055e31de1f641e422a082a
commit: aaaf5fbf56f16c81a653713cc333b18ad6e25ea9 rtc: add driver for DS1685 family of real time clocks
date:   13 days ago


coccinelle warnings: (new ones prefixed by >>)

>> drivers/rtc/rtc-ds1685.c:2144:3-8: No need to set .owner here. The core will do it.

vim +2144 drivers/rtc/rtc-ds1685.c

  2128		/* Manually clear RF/WF/KF in Ctrl 4A. */
  2129		rtc->write(rtc, RTC_EXT_CTRL_4A,
  2130			   (rtc->read(rtc, RTC_EXT_CTRL_4A) &
  2131			    ~(RTC_CTRL_4A_RWK_MASK)));
  2132	
  2133		cancel_work_sync(&rtc->work);
  2134	
  2135		return 0;
  2136	}
  2137	
  2138	/**
  2139	 * ds1685_rtc_driver - rtc driver properties.
  2140	 */
  2141	static struct platform_driver ds1685_rtc_driver = {
  2142		.driver		= {
  2143			.name	= "rtc-ds1685",
> 2144			.owner	= THIS_MODULE,
  2145		},
  2146		.probe		= ds1685_rtc_probe,
  2147		.remove		= ds1685_rtc_remove,
  2148	};
  2149	
  2150	/**
  2151	 * ds1685_rtc_init - rtc module init.
  2152	 */

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

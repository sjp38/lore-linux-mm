Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5B04982F66
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 08:49:21 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so209094767pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 05:49:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id jy15si5930642pbb.145.2015.10.06.05.49.20
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 05:49:20 -0700 (PDT)
Date: Tue, 6 Oct 2015 20:48:41 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 5509/5515] kernel/time/clocksource.c:220:7:
 error: implicit declaration of function 'abs64'
Message-ID: <201510062038.9laeRF3o%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   53e06f2de559bde769638c9608dcb8654a535654
commit: e75a4c08437638a8e81dec82074225e3c9551735 [5509/5515] Remove abs64()
config: x86_64-allnoconfig (attached as .config)
reproduce:
        git checkout e75a4c08437638a8e81dec82074225e3c9551735
        # save the attached .config to linux build tree
        make ARCH=x86_64 

Note: the linux-next/master HEAD 53e06f2de559bde769638c9608dcb8654a535654 builds fine.
      It may have been fixed somewhere.

All errors (new ones prefixed by >>):

   kernel/time/clocksource.c: In function 'clocksource_watchdog':
>> kernel/time/clocksource.c:220:7: error: implicit declaration of function 'abs64' [-Werror=implicit-function-declaration]
      if (abs64(cs_nsec - wd_nsec) > WATCHDOG_THRESHOLD) {
          ^
   cc1: some warnings being treated as errors

vim +/abs64 +220 kernel/time/clocksource.c

b52f52a0 Thomas Gleixner    2007-05-09  204  
3a978377 Thomas Gleixner    2014-07-16  205  		delta = clocksource_delta(wdnow, cs->wd_last, watchdog->mask);
3a978377 Thomas Gleixner    2014-07-16  206  		wd_nsec = clocksource_cyc2ns(delta, watchdog->mult,
3a978377 Thomas Gleixner    2014-07-16  207  					     watchdog->shift);
b5199515 Thomas Gleixner    2011-06-16  208  
3a978377 Thomas Gleixner    2014-07-16  209  		delta = clocksource_delta(csnow, cs->cs_last, cs->mask);
3a978377 Thomas Gleixner    2014-07-16  210  		cs_nsec = clocksource_cyc2ns(delta, cs->mult, cs->shift);
0b046b21 John Stultz        2015-03-11  211  		wdlast = cs->wd_last; /* save these in case we print them */
0b046b21 John Stultz        2015-03-11  212  		cslast = cs->cs_last;
b5199515 Thomas Gleixner    2011-06-16  213  		cs->cs_last = csnow;
b5199515 Thomas Gleixner    2011-06-16  214  		cs->wd_last = wdnow;
b5199515 Thomas Gleixner    2011-06-16  215  
9fb60336 Thomas Gleixner    2011-09-12  216  		if (atomic_read(&watchdog_reset_pending))
9fb60336 Thomas Gleixner    2011-09-12  217  			continue;
9fb60336 Thomas Gleixner    2011-09-12  218  
b5199515 Thomas Gleixner    2011-06-16  219  		/* Check the deviation from the watchdog clocksource. */
67dfae0c John Stultz        2015-09-14 @220  		if (abs64(cs_nsec - wd_nsec) > WATCHDOG_THRESHOLD) {
45bbfe64 Joe Perches        2015-05-25  221  			pr_warn("timekeeping watchdog: Marking clocksource '%s' as unstable because the skew is too large:\n",
45bbfe64 Joe Perches        2015-05-25  222  				cs->name);
0b046b21 John Stultz        2015-03-11  223  			pr_warn("                      '%s' wd_now: %llx wd_last: %llx mask: %llx\n",
0b046b21 John Stultz        2015-03-11  224  				watchdog->name, wdnow, wdlast, watchdog->mask);
0b046b21 John Stultz        2015-03-11  225  			pr_warn("                      '%s' cs_now: %llx cs_last: %llx mask: %llx\n",
0b046b21 John Stultz        2015-03-11  226  				cs->name, csnow, cslast, cs->mask);
0b046b21 John Stultz        2015-03-11  227  			__clocksource_unstable(cs);
8cf4e750 Martin Schwidefsky 2009-08-14  228  			continue;

:::::: The code at line 220 was first introduced by commit
:::::: 67dfae0cd72fec5cd158b6e5fb1647b7dbe0834c clocksource: Fix abs() usage w/ 64bit values

:::::: TO: John Stultz <john.stultz@linaro.org>
:::::: CC: Thomas Gleixner <tglx@linutronix.de>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--opJtzjQTFsWo+cga
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Z2IcFqDOy6Zi24QAUVQbfWBE8Af995zboVQAAA==

--opJtzjQTFsWo+cga--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

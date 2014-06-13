Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2D66B003A
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:15:59 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id fp1so1633813pdb.10
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 20:15:59 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id g7si3129501pat.225.2014.06.12.20.15.58
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 20:15:58 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:15:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 83/178] include/linux/compiler.h:346:20: error:
 call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG
 failed
Message-ID: <20140613031525.GA32562@localhost>
References: <539a5523.HESVePEonvHiA9PR%fengguang.wu@intel.com>
 <1402628344-hpyin23@n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402628344-hpyin23@n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

> > >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
> > >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed
> > >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_1330' declared with attribute error: BUILD_BUG failed

Sorry the above errors are not really new. The number part of
__compiletime_assert_NNN changes all the time, which confused
the build robot. Just fixed it up.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

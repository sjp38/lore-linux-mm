Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97A288D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 16:29:29 -0500 (EST)
Date: Fri, 4 Feb 2011 13:28:43 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
Message-ID: <20110204212843.GA18924@kroah.com>
References: <20110118172151.GA20507@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110118172151.GA20507@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, chris.mason@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Tue, Jan 18, 2011 at 09:21:51AM -0800, Dan Magenheimer wrote:
> [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
> 
> Makefiles and Kconfigs to build kztmem in drivers/staging
> 
> There is a dependency on xvmalloc.* which in 2.6.37 resides
> in drivers/staging/zram.  Should this move or disappear,
> some Makefile/Kconfig changes will be required.

There is some other kind of dependancy as well, because I get the
following errors when building:

drivers/staging/kztmem/kztmem.c:34:2: error: #error "kztmem is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
drivers/staging/kztmem/kztmem.c:531:13: warning: a??zbud_inita?? defined but not used
drivers/staging/kztmem/kztmem.c:883:28: warning: a??kztmem_hostopsa?? defined but not used
drivers/staging/kztmem/kztmem.c:988:27: warning: a??kztmem_pamopsa?? defined but not used
drivers/staging/kztmem/kztmem.c:1063:30: warning: a??kztmem_cpu_notifier_blocka?? defined but not used
drivers/staging/kztmem/kztmem.c:1201:24: warning: a??kztmem_shrinkera?? defined but not used
drivers/staging/kztmem/kztmem.c:1210:12: warning: a??kztmem_put_pagea?? defined but not used
drivers/staging/kztmem/kztmem.c:1242:12: warning: a??kztmem_get_pagea?? defined but not used
drivers/staging/kztmem/kztmem.c:1259:12: warning: a??kztmem_flush_pagea?? defined but not used
drivers/staging/kztmem/kztmem.c:1278:12: warning: a??kztmem_flush_objecta?? defined but not used
drivers/staging/kztmem/kztmem.c:1297:12: warning: a??kztmem_destroy_poola?? defined but not used
drivers/staging/kztmem/kztmem.c:1320:12: warning: a??kztmem_new_poola?? defined but not used
drivers/staging/kztmem/kztmem.c:1558:19: warning: a??enable_kztmema?? defined but not used
drivers/staging/kztmem/kztmem.c:1569:19: warning: a??no_cleancachea?? defined but not used
drivers/staging/kztmem/kztmem.c:1579:19: warning: a??no_frontswapa?? defined but not used

If you require a kbuild dependancy, then put it in your Kconfig file
please, don't break the build.

I'll not apply these patches for now until that's fixed up.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 1992E6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 20:47:15 -0500 (EST)
Date: Fri, 25 Jan 2013 12:47:00 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301250147.r0P1l00t001070@como.maths.usyd.edu.au>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
In-Reply-To: <20130125005529.GA21668@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: 695182@bugs.debian.org, akpm@linux-foundation.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Fengguang,

> There are 260MB reclaimable slab pages in the normal zone ...

Marked "all_unreclaimable? yes": is that wrong? Question asked also in:
http://marc.info/?l=linux-mm&m=135873981326767&w=2

> ... however we somehow failed to reclaim them. ...

I made a patch that would do a drop_caches at that point, please see:
http://bugs.debian.org/695182
http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=101;filename=drop_caches.patch;att=1;bug=695182
http://marc.info/?l=linux-mm&m=135785511125549&w=2
and that successfully avoided OOM when writing files.
But, the drop_caches patch did not protect against the "sleep test".

> ... What's your filesystem and the content of /proc/slabinfo?

Filesystem is EXT3. See output of slabinfo in Debian bug above or in
http://marc.info/?l=linux-mm&m=135796154427544&w=2

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

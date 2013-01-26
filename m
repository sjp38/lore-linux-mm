Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7BC556B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 22:57:50 -0500 (EST)
Date: Sat, 26 Jan 2013 14:57:29 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301260357.r0Q3vT1v005715@como.maths.usyd.edu.au>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
In-Reply-To: <20130125005529.GA21668@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: 695182@bugs.debian.org, akpm@linux-foundation.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Fengguang (et al),

> There are 260MB reclaimable slab pages in the normal zone, however we
> somehow failed to reclaim them. ...

Could the problem be that without CONFIG_NUMA, zone_reclaim_mode stays
at zero and anyway zone_reclaim() does nothing in include/linux/swap.h ?

Though... there is no CONFIG_NUMA nor /proc/sys/vm/zone_reclaim_mode in
the Ubuntu non-PAE "plain" HIGHMEM4G kernel, and still it handles the
"sleep test" just fine.

Where does reclaiming happen (or meant to happen)?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id B87356B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 04:20:47 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id s7so2823428lbd.15
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:46 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id q7si5026162lbw.8.2014.04.25.01.20.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 01:20:45 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id mc6so1682618lab.11
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:44 -0700 (PDT)
Message-Id: <20140425081030.185969086@openvz.org>
Date: Fri, 25 Apr 2014 12:10:30 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/2] A few simplifications for softdirty memory tracker code
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, hpa@zytor.com, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, akpm@linux-foundation.org, peterz@infradead.org, xemul@parallels.com, gorcunov@openvz.org

Hi, here are a few simplifications for softdirty memory tracker code, in
particular we dropped off x86-32 support since it seems noone needed it
here on x86 platform.

As Andrew requested I've rebased patches on top of current linux-next repo.

Also at first I wanted to rip off _PAGE_PSE bit which we use in swap ptes
to track dirty status of swapped pages and reuse _PAGE_BIT_SOFT_DIRTY
instead. It's still possible but requires additional shrinking of
maximal swap size and I don't know if it's acceptible or not. Currently
we have

#ifdef CONFIG_NUMA_BALANCING
/* Automatic NUMA balancing needs to be distinguishable from swap entries */
#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
#else
#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
#endif

If I reuse _PAGE_BIT_SOFT_DIRTY I'll have to increase this shift up
to bit 11, which, again, I think is too much, right?

Comments are highly appreciated!

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

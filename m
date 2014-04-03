Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 16E146B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 17:44:04 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2387846pdi.33
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 14:44:03 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id yx10si3640286pab.343.2014.04.03.14.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 14:44:02 -0700 (PDT)
Message-ID: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
Subject: [RFC] mm,tracing: improve current situation
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 03 Apr 2014 14:44:00 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

Hi All,

During LSFMM Dave Jones discussed the current situation around
testing/trinity in the mm. One of the conclusions was that basically we
lack tools to gather the necessary information to make debugging a less
painful process, making it pretty much a black box for a lot of cases.

One of the suggested ways to do so was to improve our tracing. Currently
we have events for kmem, vmscan and oom (which really just traces the
tunable updates) -- In addition Dave Hansen also also been trying to add
tracing for TLB range flushing, hopefully that can make it in some time
soon. However, this lacks the more general data that governs all of the
core VM, such as vmas and of course the mm_struct.

To this end, I've started adding events to trace the vma lifecycle,
including: creating, removing, splitting, merging, copying and
adjusting. Currently it only prints out the start and end virtual
addresses, such as:

bash-3661   [000]  ....  222.964847: split_vma: [8a8000-9a6000] => new: [9a6000-9b6000]

Now, on a more general scenario, I basically would like to know, 1) is
this actually useful... I'm hoping that, if in fact something like this
gets merged, it won't just sit there. 2) What other general data would
be useful for debugging purposes? I'm happy to collect feedback and send
out something we can all benefit from.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

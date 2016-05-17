Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9FD16B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 09:20:30 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id f14so8748953lbb.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 06:20:30 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id n4si3609296wju.71.2016.05.17.06.20.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 May 2016 06:20:29 -0700 (PDT)
From: Stefan Bader <stefan.bader@canonical.com>
Subject: mm: Use phys_addr_t for reserve_bootmem_region arguments
Date: Tue, 17 May 2016 15:20:21 +0200
Message-Id: <1463491221-10573-1-git-send-email-stefan.bader@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kernel-team@lists.ubuntu.com, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Re-posting to a hopefully better suited audience. I hit this problem
when trying to boot a i386 dom0 (PAE enabled) on a 64bit Xen host using
a config which would result in a reserved memory range starting at 4MB.
Due to the usage of unsigned long as arguments for start address and
length, this would wrap and actually mark the lower memory range staring
from 0 as reserved. Between kernel version 4.2 and 4.4 this somehow boots
but starting with 4.4 the result is a panic and reboot.

Not sure this special Xen case is the only one affected, but in general
it seems more correct to use phys_addr_t as the type for start and end
as that is the type used in the memblock region definitions and those
are 64bit (at least with PAE enabled).

-Stefan

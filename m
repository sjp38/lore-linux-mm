Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFD386B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:37:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g143so8399642wme.13
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:37:53 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m75si22174544wmc.42.2017.06.01.01.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:37:52 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id g15so9377346wmc.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:37:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] memory hotplug follow up fixes
Date: Thu,  1 Jun 2017 10:37:44 +0200
Message-Id: <20170601083746.4924-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
Heiko Carstens has noticed an unexpected memory online behavior for the
default onlining (aka MMOP_ONLINE_KEEP) and also online_kernel to other
kernel zones than ZONE_NORMAL. Both fixes are rather straightforward
so could you add them to the memory hotplug rewrite pile please?

Shortlog
Michal Hocko (2):
      mm, memory_hotplug: fix MMOP_ONLINE_KEEP behavior
      mm, memory_hotplug: do not assume ZONE_NORMAL is default kernel zone

Diffstat
 drivers/base/memory.c          |  2 +-
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 36 +++++++++++++++++++++++++++++-------
 3 files changed, 32 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

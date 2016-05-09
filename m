Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7797B6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 13:53:47 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id u23so152761037vkb.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 10:53:47 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id f65si4962696qhe.24.2016.05.09.10.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 10:53:46 -0700 (PDT)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 9 May 2016 11:53:45 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 0/3] memory-hotplug: improve rezoning capability
Date: Mon,  9 May 2016 12:53:36 -0500
Message-Id: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

While it is currently possible to rezone memory when it is onlined, there are
implicit assumptions about the zones:

* To "online_kernel" a block into ZONE_NORMAL, it must currently
  be in ZONE_MOVABLE.

* To "online_movable" a block into ZONE_MOVABLE, it must currently
  be in (ZONE_MOVABLE - 1).

So on powerpc, where new memory is hotplugged into ZONE_DMA, these operations
do not work.

This patchset replaces the qualifications above with a more general
validation of zone movement.

Reza Arbab (3):
  memory-hotplug: add move_pfn_range()
  memory-hotplug: more general validation of zone during online
  memory-hotplug: use zone_can_shift() for sysfs valid_zones attribute

 drivers/base/memory.c          | 28 ++++++++++-------
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 70 ++++++++++++++++++++++++++++++++++--------
 3 files changed, 77 insertions(+), 23 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

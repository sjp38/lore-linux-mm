Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5096B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 09:45:18 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id c6so36050574qga.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 06:45:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f125si2080552qkb.95.2016.04.06.06.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 06:45:17 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 0/2] memory_hotplug: introduce config and command line options to set the default onlining policy
Date: Wed,  6 Apr 2016 15:45:10 +0200
Message-Id: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Igor Mammedov <imammedo@redhat.com>

This patchset continues the work I started with:

commit 31bc3858ea3ebcc3157b3f5f0e624c5962f5a7a6
Author: Vitaly Kuznetsov <vkuznets@redhat.com>
Date:   Tue Mar 15 14:56:48 2016 -0700

    memory-hotplug: add automatic onlining policy for the newly added memory

Initially I was going to stop there and bring the policy setting logic to
userspace. I met two issues on this way:

1) It is possible to have memory hotplugged at boot (e.g. with QEMU). These
   blocks stay offlined if we turn the onlining policy on by userspace.

2) My attempt to bring this policy setting to systemd failed, systemd
   maintainers suggest to change the default in kernel or ... to use tmpfiles.d
   to alter the policy (which looks like a hack to me): 
   https://github.com/systemd/systemd/pull/2938

Here I suggest to add a config option to set the default value for the policy
and a kernel command line parameter to make the override.

Vitaly Kuznetsov (2):
  memory_hotplug: introduce CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
  memory_hotplug: introduce memhp_default_state= command line parameter

 Documentation/kernel-parameters.txt |  8 ++++++++
 Documentation/memory-hotplug.txt    |  9 +++++----
 mm/Kconfig                          | 16 ++++++++++++++++
 mm/memory_hotplug.c                 | 15 +++++++++++++++
 4 files changed, 44 insertions(+), 4 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

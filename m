Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6985A6B0722
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 03:59:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l23-v6so5666985qtp.1
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 00:59:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a65-v6si1438434qkg.6.2018.08.17.00.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 00:59:13 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 1/2] drivers/base: export lock_device_hotplug/unlock_device_hotplug
Date: Fri, 17 Aug 2018 09:59:00 +0200
Message-Id: <20180817075901.4608-2-david@redhat.com>
In-Reply-To: <20180817075901.4608-1-david@redhat.com>
References: <20180817075901.4608-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Hildenbrand <david@redhat.com>, "K . Y . Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Rientjes <rientjes@google.com>

From: Vitaly Kuznetsov <vkuznets@redhat.com>

Well require to call add_memory()/add_memory_resource() with
device_hotplug_lock held, to avoid a lock inversion. Allow external modules
(e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
lock device hotplug.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
[modify patch description]
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 04bbcd779e11..9010b9e942b5 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -700,11 +700,13 @@ void lock_device_hotplug(void)
 {
 	mutex_lock(&device_hotplug_lock);
 }
+EXPORT_SYMBOL_GPL(lock_device_hotplug);
 
 void unlock_device_hotplug(void)
 {
 	mutex_unlock(&device_hotplug_lock);
 }
+EXPORT_SYMBOL_GPL(unlock_device_hotplug);
 
 int lock_device_hotplug_sysfs(void)
 {
-- 
2.17.1

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id DAD206B006C
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:24:21 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id k11so9037030wes.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:24:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lo2si2151952wic.50.2015.02.12.02.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 02:24:20 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH RESEND 1/3] driver core: export lock_device_hotplug/unlock_device_hotplug
Date: Thu, 12 Feb 2015 11:23:52 +0100
Message-Id: <1423736634-338-2-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
References: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, devel@linuxdriverproject.org, linux-mm@kvack.org

add_memory() is supposed to be run with device_hotplug_lock grabbed, otherwise
it can race with e.g. device_online(). Allow external modules (hv_balloon for
now) to lock device hotplug.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/base/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 97e2baf..b3073af 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -55,11 +55,13 @@ void lock_device_hotplug(void)
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
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

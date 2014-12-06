Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DB0BE6B006C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 18:31:47 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so1574264pad.23
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 15:31:47 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTP id qa5si49711060pbc.29.2014.12.05.15.31.46
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 15:31:46 -0800 (PST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/2] Drivers: base: core: Export functions to lock/unlock device hotplug lock
Date: Fri,  5 Dec 2014 16:41:37 -0800
Message-Id: <1417826498-21172-1-git-send-email-kys@microsoft.com>
In-Reply-To: <1417826471-21131-1-git-send-email-kys@microsoft.com>
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

The Hyper-V balloon driver does memory hot-add. The device_hotplug_lock
is designed to address AB BA deadlock issues between the hot-add path
and the sysfs path. Export the APIs to acquire and release the
device_hotplug_lock for use by loadable modules that want to
hot-add memory or CPU.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/base/core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

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
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

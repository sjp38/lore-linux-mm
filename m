Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC346B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:42 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n76so150649124ioe.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 05:52:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s64si14751884pfb.54.2017.03.14.05.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 05:52:41 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2ECi9en133812
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:41 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 296gfmshse-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:52:40 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 14 Mar 2017 12:52:38 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCHv2 2/2] drivers core: remove assert_held_device_hotplug()
Date: Tue, 14 Mar 2017 13:52:26 +0100
In-Reply-To: <20170314125226.16779-1-heiko.carstens@de.ibm.com>
References: <20170314125226.16779-1-heiko.carstens@de.ibm.com>
Message-Id: <20170314125226.16779-3-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

The last caller of assert_held_device_hotplug() is gone, so remove it again.

Acked-by: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/base/core.c    | 5 -----
 include/linux/device.h | 1 -
 2 files changed, 6 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 684bda4d14a1..6bb60fb6a30b 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -639,11 +639,6 @@ int lock_device_hotplug_sysfs(void)
 	return restart_syscall();
 }
 
-void assert_held_device_hotplug(void)
-{
-	lockdep_assert_held(&device_hotplug_lock);
-}
-
 #ifdef CONFIG_BLOCK
 static inline int device_is_not_partition(struct device *dev)
 {
diff --git a/include/linux/device.h b/include/linux/device.h
index 30c4570e928d..9ef518af5515 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1140,7 +1140,6 @@ static inline bool device_supports_offline(struct device *dev)
 extern void lock_device_hotplug(void);
 extern void unlock_device_hotplug(void);
 extern int lock_device_hotplug_sysfs(void);
-void assert_held_device_hotplug(void);
 extern int device_offline(struct device *dev);
 extern int device_online(struct device *dev);
 extern void set_primary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

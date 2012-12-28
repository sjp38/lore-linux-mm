Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5B6396B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:28:59 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MFQ002RPW7EN0B0@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 28 Dec 2012 23:28:46 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MFQ004KNW7XPF60@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 28 Dec 2012 23:28:46 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [announce] Timeout Based User-space Low Memory Killer Daemon
Date: Fri, 28 Dec 2012 15:27:43 +0100
MIME-version: 1.0
Message-id: <201212281527.43430.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Anton Vorontsov <anton.vorontsov@linaro.org>


Hi,

I would like to announce the first public version of my timeout based
user-space low memory killer daemon (tbulmkd).  It is based on idea
that user-space applications can be divided into two classes,
foreground and background ones.  Foreground processes are visible in
graphical user interface (GUI) and therefore shouldn't be terminated
first when memory usage gets too high.  OTOH background processes are
no longer visible in GUI and are pro-actively being killed to keep
overall memory usage smaller.  Actual daemon implementation is heavily
based on the user-space low memory killer daemon (ulmkd) from Anton
Vorontsov (http://thread.gmane.org/gmane.linux.kernel.mm/84302).

The program is available at:

	https://github.com/bzolnier/tbulmkd

kernel/add-tbulmkd-entries.patch needs to be applied to the kernel
that would be used with tbulmkd.  It adds /proc/$pid/activity and
/proc/$pid/activity_time files.  Write '0' to activity file to mark
the process as background one and '1' (the default value) to mark
it as foreground one.  Please note that this interface is just for
a demonstration of tbulmkd functionality and will be changed in
the future.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

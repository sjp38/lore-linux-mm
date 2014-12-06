Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 468EB6B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 18:31:20 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so1573714pad.23
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 15:31:19 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTP id cg3si24800754pdb.231.2014.12.05.15.31.18
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 15:31:18 -0800 (PST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/2] Drivers: hv: hv_balloon: Fix a deadlock in the hot-add path. 
Date: Fri,  5 Dec 2014 16:41:11 -0800
Message-Id: <1417826471-21131-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

Fix a deadlock in the hot-add path in the Hyper-V balloon driver.

K. Y. Srinivasan (2):
  Drivers: base: core: Export functions to lock/unlock device hotplug
    lock
  Drivers: hv: balloon: Fix the deadlock issue in the memory hot-add
    code

 drivers/base/core.c     |    2 ++
 drivers/hv/hv_balloon.c |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

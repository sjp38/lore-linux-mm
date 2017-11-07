Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3D326B02C5
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:04:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l188so4304754wma.1
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:04:57 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r6si881769edi.539.2017.11.07.07.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 07:04:56 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 0/1] split deferred_init_range into initializing and freeing parts
Date: Tue,  7 Nov 2017 10:04:45 -0500
Message-Id: <20171107150446.32055-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As discussed last week with Michal Hocko, I am sending this as a separate
patch:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1528267.html

This patch farther improves deferred page initialization by enabling future
mult-threading, covering some corner cases, and simplifies the logic and
modularity.

Tested with qemu, and on bare metal with kexec, and regular reboots.

Pavel Tatashin (1):
  mm: split deferred_init_range into initializing and freeing parts

 mm/page_alloc.c | 146 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 76 insertions(+), 70 deletions(-)

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

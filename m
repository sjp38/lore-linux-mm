Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0650F6B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v5-v6so22934782qto.13
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:24:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e129-v6si4614575qka.244.2018.05.23.11.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 11:24:16 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 1/4] ACPI: NUMA: export pxm_to_node
Date: Wed, 23 May 2018 20:24:01 +0200
Message-Id: <20180523182404.11433-2-david@redhat.com>
In-Reply-To: <20180523182404.11433-1-david@redhat.com>
References: <20180523182404.11433-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org

Will be needed by paravirtualized memory devices.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/acpi/numa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 85167603b9c9..7ffee2959350 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -50,6 +50,7 @@ int pxm_to_node(int pxm)
 		return NUMA_NO_NODE;
 	return pxm_to_node_map[pxm];
 }
+EXPORT_SYMBOL(pxm_to_node);
 
 int node_to_pxm(int node)
 {
-- 
2.17.0

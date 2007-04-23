Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l3NNXeNS031039
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:33:40 -0700
Received: from smtp.corp.google.com (spacemonkey3.corp.google.com [192.168.120.116])
	by zps77.corp.google.com with ESMTP id l3NNXNjH018312
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:33:23 -0700
Received: from [10.253.168.165] (m682a36d0.tmodns.net [208.54.42.104])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id l3NNXKfe020128
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:33:23 -0700
Message-ID: <462D423E.4060904@google.com>
Date: Mon, 23 Apr 2007 16:33:18 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 6/7] cpuset write fixes
References: <462D3F4C.2040007@google.com>
In-Reply-To: <462D3F4C.2040007@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove unneeded local variable.

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 5/mm/page-writeback.c 6/mm/page-writeback.c
--- 5/mm/page-writeback.c	2007-04-23 15:13:15.000000000 -0700
+++ 6/mm/page-writeback.c	2007-04-23 15:14:25.000000000 -0700
@@ -177,7 +177,6 @@ get_dirty_limits(struct dirty_limits *dl
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
 	unsigned long dirtyable_memory;
 	unsigned long nr_mapped;
 	struct task_struct *tsk;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

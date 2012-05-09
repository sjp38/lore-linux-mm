Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A52086B0115
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:08 -0400 (EDT)
Message-Id: <20120509150950.243797150@linux.com>
Date: Wed, 09 May 2012 10:09:50 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 0/9] Slub: cleanups V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

V1->V2:
- Rebase against 3.4-rc6

A series of cleanup patches that resulted from the rework
of the allocation paths to not disable interrupts.

The patches remove the node field from kmem_cache_cpu and generally
cleans up code in the critical paths. The removal of the node field
increases the cache friendliness of the hotpaths and results in a
slight performance increase.

Hackbench performance before and after using 3.3-rc1

			Before		After
100 process 20000	152.3		151.2
100 process 20000	160.6		154.8
100 process 20000	161.2		155.5
10 process 20000	15.9		15.5
10 process 20000	15.7		15.5
10 process 20000	15.8		15.5
1 process 20000		1.8		1.6
1 process 20000		1.6		1.6
1 process 20000		1.7		1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

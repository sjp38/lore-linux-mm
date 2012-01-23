Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4E3D56B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:07 -0500 (EST)
Message-Id: <20120123201646.924319545@linux.com>
Date: Mon, 23 Jan 2012 14:16:46 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 0/9] Slub: cleanups V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

A series of cleanup patches that resulted from the rework
of the allocation paths to not disable interrupts.

The patches remove the node field from kmem_cache_cpu and generally
clean up code in the critical paths.

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

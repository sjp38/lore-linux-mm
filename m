Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0C89D6B0022
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:40:44 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4O9efLQ011370
	for <linux-mm@kvack.org>; Tue, 24 May 2011 02:40:41 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by kpbe17.cbf.corp.google.com with ESMTP id p4O9edga019266
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 May 2011 02:40:39 -0700
Received: by pvg13 with SMTP id 13so3410037pvg.26
        for <linux-mm@kvack.org>; Tue, 24 May 2011 02:40:39 -0700 (PDT)
Date: Tue, 24 May 2011 02:40:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] slub: export CMPXCHG_DOUBLE_CPU_FAIL to userspace
In-Reply-To: <alpine.DEB.2.00.1105130947560.24193@router.home>
Message-ID: <alpine.DEB.2.00.1105240239590.28192@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103221333130.16870@router.home> <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com> <alpine.DEB.2.00.1105120943570.24560@router.home> <alpine.DEB.2.00.1105121257550.2407@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1105130947560.24193@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org

4fdccdfbb465 ("slub: Add statistics for this_cmpxchg_double failures") 
added CMPXCHG_DOUBLE_CPU_FAIL to show how many times 
this_cpu_cmpxchg_double has failed, but it also needs to be exported to 
userspace for consumption.

This will always be 0 if CONFIG_CMPXCHG_LOCAL is disabled.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4525,6 +4525,7 @@ STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
 STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
+STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -4582,6 +4583,7 @@ static struct attribute *slab_attrs[] = {
 	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
 	&order_fallback_attr.attr,
+	&cmpxchg_double_cpu_fail_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

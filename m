Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA27547
	for <linux-mm@kvack.org>; Wed, 2 Oct 2002 14:46:46 -0700 (PDT)
Received: from schumi.digeo.com ([192.168.1.205])
 by digeo-nav01.digeo.com (NAVGW 2.5.2.12) with SMTP id M2002100214474115519
 for <linux-mm@kvack.org>; Wed, 02 Oct 2002 14:47:41 -0700
Message-ID: <3D9B6939.397DB9EA@digeo.com>
Date: Wed, 02 Oct 2002 14:46:33 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: NUMA is bust with CONFIG_PREEMPT=y
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

#define numa_node_id()  (__cpu_to_node(smp_processor_id()))

Either you're going to have to change that to get_cpu_only_on_numa() and
add the matching put_cpu_only_on_numa()'s, or disable preempt in
the config system.

Now, it's probably the case that this happens to work OK;
if you hop CPUs you just end up doing a suboptimal cross-node
operation.  But it'd be better to fix it up, IMO.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

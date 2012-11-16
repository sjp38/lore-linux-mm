Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id C6A518D0002
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:03:55 -0500 (EST)
Received: by mail-la0-f73.google.com with SMTP id d3so190055lah.2
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:03:53 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: kmem accounting netperf data
Date: Fri, 16 Nov 2012 09:03:52 -0800
Message-ID: <xr937gplwkcn.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

We ran some netperf comparisons measuring the overhead of enabling
CONFIG_MEMCG_KMEM with a kmem limit.  Short answer: no regression seen.

This is a multiple machine (client,server) netperf test.  Both client
and server machines were running the same kernel with the same
configuration.

A baseline run (with CONFIG_MEMCG_KMEM unset) was compared with a full
featured run (CONFIG_MEMCG_KMEM=y and a kmem limit large enough not to
put additional pressure on the workload).  We saw no noticeable
regression running:
- TCP_CRR efficiency, latency
- TCP_RR latency, rate
- TCP_STREAM efficiency, throughput
- UDP_RR efficiency, latency
The tests were run with a varying number of concurrent connections
(between 1 and 200).

The source came from one of Glauber's branches
(git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg
kmemcg-slab):
  commit 70506dcf756aaafd92f4a34752d6b8d8ff4ed360
  Author: Glauber Costa <glommer@parallels.com>
  Date:   Thu Aug 16 17:16:21 2012 +0400

      Add slab-specific documentation about the kmem controller

It's not the latest source, but I figured the data might still be
useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

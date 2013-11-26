Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 93E146B00A3
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:18:17 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so8641916qaq.5
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:18:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j1si24183648qer.115.2013.11.26.14.18.16
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 14:18:16 -0800 (PST)
From: riel@redhat.com
Subject: [RFC PATCH 0/4] pseudo-interleaving NUMA placement
Date: Tue, 26 Nov 2013 17:03:24 -0500
Message-Id: <1385503408-30041-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, chegu_vinod@hp.com, peterz@infradead.org

This patch set attempts to implement a pseudo-interleaving
policy for workloads that do not fit in one NUMA node.

For each NUMA group, we track the NUMA nodes on which the
workload is actively running, and try to concentrate the
memory on those NUMA nodes.

Unfortunately, the scheduler appears to move tasks around
quite a bit, leading to nodes being dropped from the
"active nodes" mask, and re-added a little later, causing
excessive memory migration.

I am not sure how to solve that. Hopefully somebody will
have an idea :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

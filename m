Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A94876B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 01:50:57 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id h33so4886490plh.19
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 22:50:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t8sor868977pgc.243.2018.02.23.22.50.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 22:50:56 -0800 (PST)
Date: Fri, 23 Feb 2018 22:50:30 -0800
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: tcp_bind_bucket is missing from slabinfo
Message-ID: <20180223225030.2e8ef122@shemminger-XPS-13-9360>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org

Somewhere back around 3.17 the kmem cache "tcp_bind_bucket" dropped out
of /proc/slabinfo. It turns out the ss command was dumpster diving
in slabinfo to determine the number of bound sockets and now it always
reports 0.

Not sure why, the cache is still created but it doesn't
show in slabinfo. Could it be some part of making slab/slub common code
(or network namespaces). The cache is created in tcp_init but not visible.

Any ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9BC6B0006
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 14:05:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q2so4431155pgf.22
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 11:05:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g27sor1471210pfg.47.2018.02.24.11.05.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Feb 2018 11:05:02 -0800 (PST)
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 0/2] mark some slabs as visible not mergeable
Date: Sat, 24 Feb 2018 11:04:52 -0800
Message-Id: <20180224190454.23716-1-sthemmin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, willy@infradead.org
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>

This fixes an old bug in iproute2's ss command because it was
reading slabinfo to get statistics. There isn't a better API
to do this, and one can argue that /proc is a UAPI that must
not change.

Therefore this patch set adds a flag to slab to give another
reason to prevent merging, and then uses it in network code.

The patches are against davem's linux-net tree and should also
goto stable as well.

Stephen Hemminger (2):
  slab: add flag to block merging of UAPI elements
  net: mark slab's used by ss as UAPI

 include/linux/slab.h | 6 ++++++
 mm/slab_common.c     | 2 +-
 net/ipv4/tcp.c       | 3 ++-
 net/ipv4/tcp_ipv4.c  | 2 +-
 net/ipv6/tcp_ipv6.c  | 2 +-
 net/socket.c         | 6 +++---
 6 files changed, 14 insertions(+), 7 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

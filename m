Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E87156B0006
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:27:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9-v6so24108620wrj.15
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:27:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 134sor3237627wmw.25.2018.04.24.22.27.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 22:27:27 -0700 (PDT)
From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp: mmap: rework zerocopy receive
Date: Tue, 24 Apr 2018 22:27:20 -0700
Message-Id: <20180425052722.73022-1-edumazet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

syzbot reported a lockdep issue caused by tcp mmap() support.

I implemented Andy Lutomirski nice suggestions to resolve the
issue and increase scalability as well.

First patch is adding a new setsockopt() operation and changes mmap()
behavior.

Second patch changes tcp_mmap reference program.

Eric Dumazet (2):
  tcp: add TCP_ZEROCOPY_RECEIVE support for zerocopy receive
  selftests: net: tcp_mmap must use TCP_ZEROCOPY_RECEIVE

 include/uapi/linux/tcp.h               |   8 ++
 net/ipv4/tcp.c                         | 186 +++++++++++++------------
 tools/testing/selftests/net/tcp_mmap.c |  63 +++++----
 3 files changed, 139 insertions(+), 118 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog

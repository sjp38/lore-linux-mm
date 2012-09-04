Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 8FEE46B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 13:24:43 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/4] Small fixes for swap-over-network
Date: Tue,  4 Sep 2012 18:24:35 +0100
Message-Id: <1346779479-1097-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Chuck Lever <chuck.lever@oracle.com>, Joonsoo Kim <js1304@gmail.com>, Pekka@suse.de, "Enberg <penberg"@kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>

This series is 4 small patches posted by Jonsoo Kim and Chuck Lever with
some minor changes applied. They are not critical but they should be fixed
before 3.6 comes out. I've picked them up and reposted to make sure they
did not get lost.

Ordinarily I would say that 1-3 should go through Pekka's slab tree and
the last patch through David Millers linux-net tree but as they are fairly
minor maybe it would be easier if all 4 went through Andrew's tree at the
same time.

The patches have been tested against 3.6-rc4 and they passed the swap over
NFS and NBD tests.

 include/net/sock.h |    2 +-
 mm/slab.c          |    6 +++---
 mm/slub.c          |   15 ++++++++++-----
 3 files changed, 14 insertions(+), 9 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

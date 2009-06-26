Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB286B008A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 16:14:40 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 26 Jun 2009 16:15:03 -0400
Message-Id: <20090626201503.29365.39994.sendpatchset@lts-notebook>
Subject: [PATCH 0/1] Balance Freeing of Huge Pages across Nodes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH] 0/1 Free huge pages round robin to balance across nodes

I posted an earlier version of the patch following this message
as part of a larger series.  I think this patch might be ready
for a ride in mmotm, so I'm sending it out separately.  I'll
base subsequent "huge pages controls" series atop this patch.

Mel Gorman agreed, in principle, that this patch was needed
independent from the huge pages controls.  However, he
suggested some cleanup, which this version addresses [and
then some], and he did not ACK the previous version.

David Rientjes did ACK the previous version, but because this
version includes a fair amount of additional mods to
adjust_pool_surplus(), I did not include his ACK.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

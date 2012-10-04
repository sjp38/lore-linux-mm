Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6BEA26B0129
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:09:27 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] memcg fixups that fell through cracks in 3.5
Date: Thu,  4 Oct 2012 14:09:15 -0400
Message-Id: <1349374157-20604-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

an older version of "mm: memcg: count pte references from every member
of the reclaimed hierarchy" patch made it into the 3.5
(c3ac9a8ade65ccbfd145fbff895ae8d8d62d09b0) by accident and I didn't
notice until just now.  #1 is a fixup on top, tagged for 3.5-stable.

#2 is a cleanup you requested but probably missed as it was attached
to a mail buried in the thread.  For 3.6.

Patches against mm.git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

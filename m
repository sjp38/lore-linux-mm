Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E475D6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:01 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK90hD027988
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:00 -0500
Received: from random.random (ovpn01.gateway.prod.ext.phx2.redhat.com [10.5.9.1])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK8xxC032003
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:00 -0500
Message-Id: <20100226200433.516502198@redhat.com>
Date: Fri, 26 Feb 2010 21:04:33 +0100
From: aarcange@redhat.com
Subject: [patch 00/35] Transparent Hugepage support #12
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This adds more commentary to khugepaged and it adds two defrag sysfs knobs:

find /sys/ -name defrag
/sys/kernel/mm/transparent_hugepage/defrag
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag

find /sys/ -name defrag -exec cat {} \;
always [madvise] never
[yes] no

This should also fix memcg khugepaged accounting (thanks Kame).

I folded the page_anon_vma patch into transparent_hugepage. It was however good
idea to keep it separated first time around IMHO to make reviewing of the
changes feasible (it's still there to review on the list in the #11 submit if
others wants to review).

Let me know if something else is needed to merge into -mm.

After that we can start to call memory compaction in alloc_hugepage(int defrag)
if defrag == 1.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

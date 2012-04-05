Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 606056B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:43:29 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1026807yen.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 09:43:28 -0700 (PDT)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 0/2] Documentation: mm: Add missing compact_node in vm.txt 
Date: Fri,  6 Apr 2012 01:42:29 +0900
Message-Id: <1333644149-31247-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>, Mel Gorman <mgorman@suse.de>, "riel@redhat.com\"" <riel@redhat.com>

First patch add missing compact_node in vm.txt.
2nd patch correct a path to extfrag_index.

Cc: Mel Gorman <mgorman@suse.de>
Cc: riel@redhat.com" <riel@redhat.com>


Masanari Iida (2):
  Documentation: mm: Add compact_node in Documentation/sysctl/vm.txt
  Documentation: mm: Fix path to extfrag_index in vm.txt

 Documentation/sysctl/vm.txt |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

-- 
1.7.10.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

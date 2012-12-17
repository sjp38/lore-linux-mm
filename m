Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 99F936B005A
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:13:35 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] page reclaim bits v2
Date: Mon, 17 Dec 2012 13:12:30 -0500
Message-Id: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

I dropped the controversial change of the meaning of !swappiness for
memcg and instead made the two changes into one cleanup patch to spell
out the conditions in get_scan_count() more explicitely.

Aside from that, I expanded the changelogs with statistics and numbers
where there was confusion about the benefits and added the review tags
to the patches that didn't otherwise change.  Let me know if I missed
any review feedback, but I think I have it all addressed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

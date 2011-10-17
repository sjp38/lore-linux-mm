Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7D7576B0030
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 17:33:17 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: fix two more s390/sparc gup_fast bugs
Date: Mon, 17 Oct 2011 23:32:50 +0200
Message-Id: <1318887172-5854-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1316793432.9084.47.camel@twins>
References: <1316793432.9084.47.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi,

I just noticed return 0 was missing after rolling back *nr, that's not
ok as then gup_fast wouldn't abort and it would put pages in the wrong
offset in the array I think... This isn't related to the recent
changes, it was the same in 2.6.37. I don't think it's ok to return 1
after rolling back *nr.

These next two are incremental with the previous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

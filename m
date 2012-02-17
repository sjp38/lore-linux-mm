Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BE9C86B0092
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 04:25:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D18343EE0B6
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:25:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2DF845DE53
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:25:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 949FF45DD75
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:25:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87DCF1DB8041
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:25:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E2431DB8037
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:25:54 +0900 (JST)
Date: Fri, 17 Feb 2012 18:24:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/6] page cgroup diet v5
Message-Id: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>


This patch set is for removing 2 flags PCG_FILE_MAPPED and PCG_MOVE_LOCK on
page_cgroup->flags. After this, page_cgroup has only 3bits of flags.
And, this set introduces a new method to update page status accounting per memcg.
With it, we don't have to add new flags onto page_cgroup if 'struct page' has
information. This will be good for avoiding a new flag for page_cgroup.

Fixed pointed out parts.
 - added more comments
 - fixed texts
 - removed redundant arguments.

Passed some tests on 3.3.0-rc3-next-20120216.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

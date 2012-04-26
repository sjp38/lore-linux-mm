Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id F2B156B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 19:57:09 -0400 (EDT)
Date: Fri, 27 Apr 2012 01:57:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, thp: drop page_table_lock to uncharge memcg pages
Message-ID: <20120426235700.GC1788@cmpxchg.org>
References: <alpine.DEB.2.00.1204261556100.15785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204261556100.15785@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Thu, Apr 26, 2012 at 03:57:30PM -0700, David Rientjes wrote:
> mm->page_table_lock is hotly contested for page fault tests and isn't
> necessary to do mem_cgroup_uncharge_page() in do_huge_pmd_wp_page().
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Probably rare, but since it's just two lines and the uncharge path
really does a ridiculous amount of things, I'm happy with moving it
out of the locked section.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

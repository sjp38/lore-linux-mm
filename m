Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id DA1D36B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 22:03:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 34AF53EE0C5
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:03:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EEDD45DEBA
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:03:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A3EB45DEB8
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:03:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A3391DB8045
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:03:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D39EC1DB8041
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 11:03:47 +0900 (JST)
Message-ID: <4F98AC9A.2080001@jp.fujitsu.com>
Date: Thu, 26 Apr 2012 11:02:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: memcg: move pc lookup point to commit_charge()
References: <1335295860-28919-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335295860-28919-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/04/25 4:31), Johannes Weiner wrote:

> None of the callsites actually need the page_cgroup descriptor
> themselves, so just pass the page and do the look up in there.
> 
> We already had two bugs (6568d4a 'mm: memcg: update the correct soft
> limit tree during migration' and 'memcg: fix Bad page state after
> replace_page_cache') where the passed page and pc were not referring
> to the same page frame.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Hugh Dickins <hughd@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

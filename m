Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 49BC76B0087
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:37:39 -0500 (EST)
Received: by qcsd17 with SMTP id d17so10882119qcs.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:37:38 -0800 (PST)
Message-ID: <4F000D40.2070408@gmail.com>
Date: Sun, 01 Jan 2012 02:37:36 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <alpine.LSU.2.00.1112312329240.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312329240.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org

(1/1/12 2:30 AM), Hugh Dickins wrote:
> I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
> to obscure the LRU counts.  For easier searching?  So call it
> lru_size rather than bare count (lru_length sounds better, but
> would be wrong, since each huge page raises lru_size hugely).
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

I don't dislike both before and after. so, I'm keeping neutral. :-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

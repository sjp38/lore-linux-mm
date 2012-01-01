Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id EC2246B0096
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:38:15 -0500 (EST)
Received: by qcsd17 with SMTP id d17so10882233qcs.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:38:15 -0800 (PST)
Message-ID: <4F000D64.3010006@gmail.com>
Date: Sun, 01 Jan 2012 02:38:12 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] memcg: enum lru_list lru
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <alpine.LSU.2.00.1112312330460.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312330460.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org

(1/1/12 2:31 AM), Hugh Dickins wrote:
> Mostly we use "enum lru_list lru": change those few "l"s to "lru"s.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

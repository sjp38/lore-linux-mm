Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 917076B0099
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:51:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1CA743EE0BD
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:51:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02DE245DE68
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:51:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B25C45DE61
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:51:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 701A51DB8038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:51:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C19E1DB803A
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:51:24 +0900 (JST)
Date: Mon, 12 Dec 2011 09:50:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix a typo in documentation
Message-Id: <20111212095011.c3b7b1db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323476120-8964-1-git-send-email-yinghan@google.com>
References: <1323476120-8964-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Fri,  9 Dec 2011 16:15:20 -0800
Ying Han <yinghan@google.com> wrote:

> A tiny typo on mapped_file stat.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  Documentation/cgroups/memory.txt |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 070c016..c0f409e 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -410,7 +410,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
>  
>  total_cache		- sum of all children's "cache"
>  total_rss		- sum of all children's "rss"
> -total_mapped_file	- sum of all children's "cache"
> +total_mapped_file	- sum of all children's "mapped_file"
>  total_mlock		- sum of all children's "mlock"
>  total_pgpgin		- sum of all children's "pgpgin"
>  total_pgpgout		- sum of all children's "pgpgout"

Thanks,
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

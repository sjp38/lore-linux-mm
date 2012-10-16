Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 7BB566B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:51:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3FC193EE0C7
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:51:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5B0545DEBC
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:51:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE8B45DEBB
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:51:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA28C1DB8040
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:51:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF5E1DB803F
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:51:18 +0900 (JST)
Message-ID: <507CAF77.1020409@jp.fujitsu.com>
Date: Tue, 16 Oct 2012 09:51:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] doc: describe memcg swappiness more precisely memory.swappiness==0
References: <20121011085038.GA29295@dhcp22.suse.cz> <1349945859-1350-1-git-send-email-mhocko@suse.cz> <20121015220354.GA11682@dhcp22.suse.cz> <20121015220725.GB11682@dhcp22.suse.cz>
In-Reply-To: <20121015220725.GB11682@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

(2012/10/16 7:07), Michal Hocko wrote:
> And a follow up for memcg.swappiness documentation which is more
> specific about spwappiness==0 meaning.
> ---
>  From 1bc3a94fea728107ed108edd42df464b908cd067 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 15 Oct 2012 11:43:56 +0200
> Subject: [PATCH] doc: describe memcg swappiness more precisely
>
> since fe35004f (mm: avoid swapping out with swappiness==0) memcg reclaim
> stopped swapping out anon pages completely when 0 value is used.
> Although this is somehow expected it hasn't been done for a really long
> time this way and so it is probably better to be explicit about the
> effect. Moreover global reclaim swapps out even when swappiness is 0
> to prevent from OOM killer.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Nice :)
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   Documentation/cgroups/memory.txt |    4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index c07f7b4..71c4da4 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -466,6 +466,10 @@ Note:
>   5.3 swappiness
>
>   Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
> +Please note that unlike the global swappiness, memcg knob set to 0
> +really prevents from any swapping even if there is a swap storage
> +available. This might lead to memcg OOM killer if there are no file
> +pages to reclaim.
>
>   Following cgroups' swappiness can't be changed.
>   - root cgroup (uses /proc/sys/vm/swappiness).
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

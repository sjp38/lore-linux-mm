Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 44AC56B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 21:10:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D74F73EE0C2
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:10:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE82745DE50
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:10:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 936CD45DE4E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:10:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80BE91DB8046
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:10:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AA801DB803F
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:10:05 +0900 (JST)
Message-ID: <4F692A0D.2030305@jp.fujitsu.com>
Date: Wed, 21 Mar 2012 10:08:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Do not open code accesses to res_counter members
References: <1332262424-13484-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1332262424-13484-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/03/21 1:53), Glauber Costa wrote:

> We should use the acessor res_counter_read_u64 for that.
> Although a purely cosmetic change is sometimes better of delayed,
> to avoid conflicting with other people's work, we are starting to
> have people touching this code as well, and reproducing the open
> code behavior because that's the standard =)
> 
> Time to fix it, then.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

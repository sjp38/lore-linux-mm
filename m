Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BC3936B0092
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 19:52:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E53723EE0BC
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:52:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF7A845DE9E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:52:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F2B45DE7E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:52:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A93EB1DB803B
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:52:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 642C61DB8038
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 08:52:50 +0900 (JST)
Message-ID: <4F973C66.2090307@jp.fujitsu.com>
Date: Wed, 25 Apr 2012 08:51:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] Documentation: memcg: future proof hierarchical statistics
 documentation
References: <1335296038-29297-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335296038-29297-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/04/25 4:33), Johannes Weiner wrote:

> The hierarchical versions of per-memcg counters in memory.stat are all
> calculated the same way and are all named total_<counter>.
> 
> Documenting the pattern is easier for maintenance than listing each
> counter twice.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Ying Han <yinghan@google.com>


I'm fine with this.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

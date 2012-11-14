Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id AF9056B0072
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 19:13:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4A8953EE0C1
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:13:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 282C945DEBC
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:13:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09B3645DEB5
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:13:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C67F3E08003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:13:44 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75DED1DB803F
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:13:44 +0900 (JST)
Message-ID: <50A2E229.3050809@jp.fujitsu.com>
Date: Wed, 14 Nov 2012 09:13:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] rework mem_cgroup iterator
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

(2012/11/14 0:30), Michal Hocko wrote:
> Hi all,
> this patch set tries to make mem_cgroup_iter saner in the way how it
> walks hierarchies. css->id based traversal is far from being ideal as it
> is not deterministic because it depends on the creation ordering.
> 
> Diffstat looks promising but it is fair the say that the biggest cleanup is
> just css_get_next removal. The memcg code has grown a bit but I think it is
> worth the resulting outcome (the sanity ;)).
> 
> The first patch fixes a potential misbehaving which I haven't seen but the
> fix is needed for the later patches anyway. We could take it alone as well
> but I do not have any bug report to base the fix on.
> 
> The second patch replaces css_get_next by cgroup iterators which are
> scheduled for 3.8 in Tejun's tree and I depend on the following two patches:
> fe1e904c cgroup: implement generic child / descendant walk macros
> 7e187c6c cgroup: use rculist ops for cgroup->children
> 
> The third patch is an attempt for simplification of the mem_cgroup_iter. It
> basically removes all css usages to make the code easier. The next patch
> removes the big while(!memcg) loop around the iterating logic. It could have
> been folded into #3 but I rather have the rework separate from the code
> moving noise.
> 
> The last patch just removes css_get_next as there is no user for it any
> longer.
> 
> I am also thinking that leaf-to-root iteration makes more sense but this
> patch is not included in the series yet because I have to think some
> more about the justification.
> 
> So far I didn't get to testing but I am posting this early if everybody is
> OK with this change.
> 
> Any thoughts?
> 

I'm O.K. Maybe I have some points I'm not understanding...I'll make a reply to patches.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

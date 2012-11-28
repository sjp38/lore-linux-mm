Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0B3C66B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 03:39:10 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 249143EE0CB
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:39:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DDAA45DEC2
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:39:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 646C345DEC0
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:39:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 554051DB8041
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:39:06 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAA111DB8059
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:39:05 +0900 (JST)
Message-ID: <50B5CD94.5020105@jp.fujitsu.com>
Date: Wed, 28 Nov 2012 17:38:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2 2/6] memcg: keep prev's css alive for the whole mem_cgroup_iter
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-3-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2012/11/27 3:47), Michal Hocko wrote:
> css reference counting keeps the cgroup alive even though it has been
> already removed. mem_cgroup_iter relies on this fact and takes a
> reference to the returned group. The reference is then released on the
> next iteration or mem_cgroup_iter_break.
> mem_cgroup_iter currently releases the reference right after it gets the
> last css_id.
> This is correct because neither prev's memcg nor cgroup are accessed
> after then. This will change in the next patch so we need to hold the
> group alive a bit longer so let's move the css_put at the end of the
> function.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

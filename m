Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8810C6B007D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 23:12:51 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 251563EE0B6
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:12:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B7F845DEC2
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:12:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD06A45DEBC
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:12:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF06B1DB8038
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:12:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AE821DB803E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:12:49 +0900 (JST)
Message-ID: <50B8322D.7050104@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 13:12:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2 6/6] cgroup: remove css_get_next
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-7-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2012/11/27 3:47), Michal Hocko wrote:
> Now that we have generic and well ordered cgroup tree walkers there is
> no need to keep css_get_next in the place.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Hm, then, the next think will be css_is_ancestor() etc..

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

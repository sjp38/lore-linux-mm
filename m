Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 92D016B005A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 21:13:17 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 904663EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:13:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 776B745DEB2
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:13:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BAE345DEB6
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:13:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EF841DB8041
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:13:15 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B0D1DB8040
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:13:14 +0900 (JST)
Message-ID: <50A44FA0.5010305@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 11:12:48 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] rework mem_cgroup iterator
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz> <50A2F9FC.5050303@huawei.com>
In-Reply-To: <50A2F9FC.5050303@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

(2012/11/14 10:55), Li Zefan wrote:
> On 2012/11/13 23:30, Michal Hocko wrote:
>> Hi all,
>> this patch set tries to make mem_cgroup_iter saner in the way how it
>> walks hierarchies. css->id based traversal is far from being ideal as it
>> is not deterministic because it depends on the creation ordering.
>>
>> Diffstat looks promising but it is fair the say that the biggest cleanup is
>> just css_get_next removal. The memcg code has grown a bit but I think it is
>> worth the resulting outcome (the sanity ;)).
>>
> 
> So memcg won't use css id at all, right? Then we can remove the whole css_id
> stuff, and that's quite a bunch of code.
> 
It's used by swap information recording for saving spaces.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

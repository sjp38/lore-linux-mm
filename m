Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id F0FCB6B000A
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 03:13:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0A44B3EE0C0
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:13:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E456945DEBE
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:13:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB2B045DEC4
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:13:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1ECF1DB803B
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:13:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 669361DB8041
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:13:44 +0900 (JST)
Message-ID: <511DEE21.9030700@jp.fujitsu.com>
Date: Fri, 15 Feb 2013 17:13:21 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/6] memcg: rework mem_cgroup_iter to use cgroup iterators
References: <1360848396-16564-1-git-send-email-mhocko@suse.cz> <1360848396-16564-3-git-send-email-mhocko@suse.cz> <511DEBBD.1050102@jp.fujitsu.com> <20130215081122.GB31032@dhcp22.suse.cz>
In-Reply-To: <20130215081122.GB31032@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

(2013/02/15 17:11), Michal Hocko wrote:
> On Fri 15-02-13 17:03:09, KAMEZAWA Hiroyuki wrote:
				css_get(&curr->css);
>> I'm sorry if I miss something...
>>
>> This curr is  curr == memcg = mem_cgroup_from_css(css) <= already try_get() done.
>> double refcounted ?
>
> Yes we get 2 references here. One for the returned memcg - which will be
> released either by mem_cgroup_iter_break or a next iteration round
> (where it would be prev) and the other is for last_visited which is
> released when a new memcg is cached.
>
Sure.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

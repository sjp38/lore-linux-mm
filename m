Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8000A6B00E8
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:17:02 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 207703EE0BC
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:17:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED32145DE5B
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:17:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D3D4145DE54
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:17:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C1D671DB8040
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:17:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C8DE1DB804C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:17:00 +0900 (JST)
Message-ID: <4F8E6A00.50707@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:15:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
References: <4F86B9BE.8000105@jp.fujitsu.com> <CALWz4izGo4aCyC7xbWyL+yfNiaUmZXPwD8bLgJVpqtcAGfyJ9w@mail.gmail.com>
In-Reply-To: <CALWz4izGo4aCyC7xbWyL+yfNiaUmZXPwD8bLgJVpqtcAGfyJ9w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/18 2:35), Ying Han wrote:

> On Thu, Apr 12, 2012 at 4:17 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
>> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.
>>
>> By pre_destroy(), rmdir of cgroup can return -EBUSY or some error.
>> It makes cgroup complicated and unstable. I said O.K. to remove it and
>> this patch is modification for memcg.
>>
>> One of problem in current implementation is that memcg moves all charges to
>> parent in pre_destroy(). At doing so, if use_hierarchy=0, pre_destroy() may
>> hit parent's limit and may return -EBUSY. To fix this problem, this patch
>> changes behavior of rmdir() as
>>
>>  - if use_hierarchy=0, all remaining charges will go to root cgroup.
>>  - if use_hierarchy=1, all remaining charges will go to the parent.
> 
> 
> We need to update the "4.3 Removing a cgroup" session in Documentation.
> 


Sure, will do.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

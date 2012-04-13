Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id C220A6B00EA
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 21:03:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D4E513EE0C3
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:03:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1EF645DE56
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:03:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9606645DE50
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:03:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 811B11DB8048
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:03:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 344FA1DB803E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:03:00 +0900 (JST)
Message-ID: <4F877AD9.6040504@jp.fujitsu.com>
Date: Fri, 13 Apr 2012 10:01:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] memcg: remove 'uncharge' argument from mem_cgroup_move_account()
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BB5E.6080509@jp.fujitsu.com> <4F86D84C.1050508@parallels.com>
In-Reply-To: <4F86D84C.1050508@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/12 22:27), Glauber Costa wrote:

> On 04/12/2012 08:24 AM, KAMEZAWA Hiroyuki wrote:
>> Only one call passes 'true'. remove it and handle it in caller.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> I like the change. I won't ack the patch itself, though, because it has
> a dependency with the "need_cancel" thing you introduced in your last
> patch - that I need to think a bit more.
> 


I'll check the logic again. Firstly, maybe name of the variable is wrong..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

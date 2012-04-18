Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1C23B6B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:04:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9A0893EE0AE
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D64C45DEB3
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6001545DE7E
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F0691DB803F
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 076C61DB8038
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:04:21 +0900 (JST)
Message-ID: <4F8E6703.70101@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:02:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] memcg: move charges to root at rmdir()
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BB02.2060607@jp.fujitsu.com> <20120416223012.GD12421@google.com>
In-Reply-To: <20120416223012.GD12421@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/17 7:30), Tejun Heo wrote:

> Hello,
> 
> On Thu, Apr 12, 2012 at 08:22:42PM +0900, KAMEZAWA Hiroyuki wrote:
>> As recently discussed, Tejun Heo, the cgroup maintainer, tries to
>> remove ->pre_destroy() and cgroup will never return -EBUSY at rmdir().
> 
> I'm not trying to remove ->pre_destory() per-se.  I want to remove css
> ref draining and ->pre_destroy() vetoing cgroup removal.  Probably
> better wording would be "tries to simplify removal path such that
> removal always succeeds".
> 


Ok.

>> To do that, in memcg, handling case of use_hierarchy==false is a problem.
>>
>> We move memcg's charges to its parent at rmdir(). If use_hierarchy==true,
>> it's already accounted in the parent, no problem. If use_hierarchy==false,
>> we cannot guarantee we can move all charges to the parent.
>>
>> This patch changes the behavior to move all charges to root_mem_cgroup
>> if use_hierarchy=false. It seems this matches semantics of use_hierarchy==false,which means parent and child has no hierarchical relationship.
> 
> Maybe better to break the above line?
> 

yes, I'll fix it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

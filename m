Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 42A666B00E8
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:14:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CF4AC3EE0BC
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:14:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B41AA45DEB7
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:14:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E987545DEB5
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:14:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D96191DB8040
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:14:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F24B1DB803B
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:14:07 +0900 (JST)
Message-ID: <4F8E6952.9030909@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:12:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] memcg: remove pre_destroy()
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BCCE.5050802@jp.fujitsu.com> <20120416223800.GF12421@google.com>
In-Reply-To: <20120416223800.GF12421@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/17 7:38), Tejun Heo wrote:

> Hello,
> 
> On Thu, Apr 12, 2012 at 08:30:22PM +0900, KAMEZAWA Hiroyuki wrote:
>> +/*
>> + * This function is called after ->destroy(). So, we cannot access cgroup
>> + * of this memcg.
>> + */
>> +static void mem_cgroup_recharge(struct work_struct *work)
> 
> So, ->pre_destroy per-se isn't gonna go away.  It's just gonna be this
> callback which cgroup core uses to unilaterally notify that the cgroup
> is going away, so no need to do this cleanup asynchronously from
> ->destroy().  It's okay to keep doing it synchronously from
> ->pre_destroy().  The only thing is that it can't fail.
> 


I see. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

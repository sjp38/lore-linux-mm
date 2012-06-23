Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5E5176B028D
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 00:25:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 542EA3EE0BB
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:25:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39D2B45DEB5
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:25:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E61E45DEA6
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:25:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E24A1DB8038
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:25:12 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B68AB1DB803E
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:25:11 +0900 (JST)
Message-ID: <4FE544A2.1050500@jp.fujitsu.com>
Date: Sat, 23 Jun 2012 13:22:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memcg: cleanup typos in mem cgroup
References: <1340369199-29535-1-git-send-email-liwp.linux@gmail.com> <20120622150358.GB16628@tiehlicka.suse.cz> <20120623021547.GA2227@kernel>
In-Reply-To: <20120623021547.GA2227@kernel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/06/23 11:16), Wanpeng Li wrote:
> On Fri, Jun 22, 2012 at 05:03:59PM +0200, Michal Hocko wrote:
>> Have you used any tool to find those typos? Have you gone through the
>> whole memcontrol.c file?
>> I am not agains fixes like this but I would much prefer if it was one
>> batch of all fixes. I bet there are more typose ;)
>
> OK, I will figure out them and resend the patch.
>

It's helpful. Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

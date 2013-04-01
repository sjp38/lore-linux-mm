Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 52D676B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:28:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E44083EE0C1
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:28:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B2A4A45DEBE
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:28:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9928345DEB7
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:28:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C4E2E08004
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:28:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4114B1DB8038
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:28:01 +0900 (JST)
Message-ID: <51595311.7070509@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 18:27:45 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: implement boost mode
References: <1364801670-10241-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1364801670-10241-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>

(2013/04/01 16:34), Glauber Costa wrote:
> There are scenarios in which we would like our programs to run faster.
> It is a hassle, when they are contained in memcg, that some of its
> allocations will fail and start triggering reclaim. This is not good
> for the program, that will now be slower.
> 
> This patch implements boost mode for memcg. It exposes a u64 file
> "memcg boost". Every time you write anything to it, it will reduce the
> counters by ~20 %. Note that we don't want to actually reclaim pages,
> which would defeat the very goal of boost mode. We just make the
> res_counters able to accomodate more.
> 
> This file is also available in the root cgroup. But with a slightly
> different effect. Writing to it will make more memory physically
> available so our programs can profit.
> 
> Please ack and apply.
> 
Nack.

> Signed-off-by: Glauber Costa <glommer@parallels.com>

Please update limit temporary. If you need call-shrink-explicitly-by-user, 
I think you can add it.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

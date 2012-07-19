Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 8E4266B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:25:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2B3893EE0AE
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:25:26 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1159945DE50
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:25:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E99DE45DD74
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:25:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB1CF1DB803C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:25:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93B9D1DB8038
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:25:25 +0900 (JST)
Message-ID: <5007E00B.6000802@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 19:23:07 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/memcg: use exist interface to get css from memcg
References: <1342609734-22437-1-git-send-email-liwanp@linux.vnet.ibm.com> <20120719092928.GA2864@tiehlicka.suse.cz>
In-Reply-To: <20120719092928.GA2864@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>

(2012/07/19 18:29), Michal Hocko wrote:
> On Wed 18-07-12 19:08:54, Wanpeng Li wrote:
>> use exist interface mem_cgroup_css instead of &mem->css.
>
> This interface has been added to enable mem->css outside of
> mm/memcontrol.c (where we define struct mem_cgroup). There is one user
> left (hwpoison_filter_task) after recent clean ups.
>
> I think we shouldn't spread the usage inside the mm/memcontrol.c. The
> compiler inlines the function for all callers added by this patch but I
> wouldn't rely on it. It is also unfortunate that we cannot convert all
> dereferences (e.g. const mem_cgroup).
> Moreover it doesn't add any additional type safety. So I would vote for
> not taking the patch but if others like it I will not block it.
>

Agreed.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

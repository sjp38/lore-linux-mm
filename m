Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 126C16B0078
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:28:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 10:22:11 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6JASKU76095256
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 20:28:20 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JASJA9021798
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 20:28:20 +1000
Date: Thu, 19 Jul 2012 18:28:18 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/memcg: use exist interface to get css from memcg
Message-ID: <20120719102818.GA20171@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1342609734-22437-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120719092928.GA2864@tiehlicka.suse.cz>
 <5007E00B.6000802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5007E00B.6000802@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>

On Thu, Jul 19, 2012 at 07:23:07PM +0900, Kamezawa Hiroyuki wrote:
>(2012/07/19 18:29), Michal Hocko wrote:
>>On Wed 18-07-12 19:08:54, Wanpeng Li wrote:
>>>use exist interface mem_cgroup_css instead of &mem->css.
>>
>>This interface has been added to enable mem->css outside of
>>mm/memcontrol.c (where we define struct mem_cgroup). There is one user
>>left (hwpoison_filter_task) after recent clean ups.
>>
>>I think we shouldn't spread the usage inside the mm/memcontrol.c. The
>>compiler inlines the function for all callers added by this patch but I
>>wouldn't rely on it. It is also unfortunate that we cannot convert all
>>dereferences (e.g. const mem_cgroup).
>>Moreover it doesn't add any additional type safety. So I would vote for
>>not taking the patch but if others like it I will not block it.
>>
>
>Agreed.

Hmm, I see, thank you. :-)

Best Regards,
Wanpeng Li
>
>-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

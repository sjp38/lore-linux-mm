Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D23C76B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:05:24 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C5D363EE0C0
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:05:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD2EA45DE4F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:05:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F96E45DE52
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:05:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F2EE08006
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:05:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E75F1DB803F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:05:22 +0900 (JST)
Message-ID: <4FDFC179.3050203@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 09:02:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: add unlikely to mercg->move_charge_at_immigrate
References: <1340025022-7272-1-git-send-email-liwp.linux@gmail.com> <4FDF2890.3020004@parallels.com> <20120618131918.GA2600@kernel>
In-Reply-To: <20120618131918.GA2600@kernel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

(2012/06/18 22:19), Wanpeng Li wrote:
> On Mon, Jun 18, 2012 at 05:09:36PM +0400, Glauber Costa wrote:
>> On 06/18/2012 05:10 PM, Wanpeng Li wrote:
>>> From: Wanpeng Li<liwp@linux.vnet.ibm.com>
>>>
>>> move_charge_at_immigrate feature is disabled by default. Charges
>>> are moved only when you move mm->owner and it also add additional
>>> overhead.
>>
>> How big is this overhead?
>>
>> That's hardly a fast path. And if it happens to matter, it will be
>> just bigger when you enable it, and the compiler start giving the
>> wrong hints to the code.
>
> Thank you for your quick response.
>
> Oh, Maybe I should just write comments "move_charge_at_immigrate feature
> is disabled by default. So add "unlikely", in order to compiler can optimize."
>

This doesn't affect the performance. likely/unlikely which doesn't affect
performance is never welcomed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

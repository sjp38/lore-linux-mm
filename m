Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7BE9A6B004D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:21:48 -0400 (EDT)
Message-ID: <4FDF2AD6.7060606@parallels.com>
Date: Mon, 18 Jun 2012 17:19:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: add unlikely to mercg->move_charge_at_immigrate
References: <1340025022-7272-1-git-send-email-liwp.linux@gmail.com> <4FDF2890.3020004@parallels.com> <20120618131918.GA2600@kernel>
In-Reply-To: <20120618131918.GA2600@kernel>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On 06/18/2012 05:19 PM, Wanpeng Li wrote:
> On Mon, Jun 18, 2012 at 05:09:36PM +0400, Glauber Costa wrote:
>> On 06/18/2012 05:10 PM, Wanpeng Li wrote:
>>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
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

Again, do you have any reason to optimize that ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

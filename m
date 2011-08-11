Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 13A55900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:21:25 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p7B8F5Ig015607
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:15:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7B8LLjm1388610
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:21:21 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7B8LJZl018832
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:21:21 +1000
Message-ID: <4E4390FC.7090103@linux.vnet.ibm.com>
Date: Thu, 11 Aug 2011 13:51:16 +0530
From: Raghavendra K T <raghukt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2][cleanup] memcg: renaming of mem variable to memcg
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com> <20110810172942.23280.99644.sendpatchset@oc5400248562.ibm.com> <20110811080500.GC8023@tiehlicka.suse.cz>
In-Reply-To: <20110811080500.GC8023@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>

On 08/11/2011 01:35 PM, Michal Hocko wrote:
> On Wed 10-08-11 22:59:42, Raghavendra K T wrote:
>>   The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
>>   "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in header file.
>
> Any reason (other than that this is a different file) to have this as a
> separate patch?
>
Yes you are right, There is no much significant reason. since source 
file patch was so huge and viable for conflicts, thought it would apply 
clean easily.
>>
>> From: Raghavendra K T<raghavendra.kt@linux.vnet.ibm.com>
>> Signed-off-by: Raghavendra K T<raghavendra.kt@linux.vnet.ibm.com>
>> ---
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 5633f51..fb1ed1c 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -88,8 +88,8 @@ extern void mem_cgroup_uncharge_end(void);
>>   extern void mem_cgroup_uncharge_page(struct page *page);
>>   extern void mem_cgroup_uncharge_cache_page(struct page *page);
(snip)
>>   }
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

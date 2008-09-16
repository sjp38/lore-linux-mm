From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <16455627.1221570144641.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 16 Sep 2008 22:02:24 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 11/9] lazy lru free vector for memcg
In-Reply-To: <48CFA549.5010500@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48CFA549.5010500@openvz.org>
 <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>	<20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>	<48CA9500.5060309@linux.vnet.ibm.com>	<20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com> <20080916211934.25c36d20.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>[snip]
>
>> @@ -938,6 +1047,7 @@ static int mem_cgroup_force_empty(struct
>>  	 * So, we have to do loop here until all lists are empty.
>>  	 */
>>  	while (mem->res.usage > 0) {
>> +		drain_page_cgroup_all();
>
>Shouldn't we wait here till the drain process completes?
>
I thought schedule_on_each_cpu() watis for completion of the work.
I'll check it, again.

Thank you for review.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

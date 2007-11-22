From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <20501143.1195738270607.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 22 Nov 2007 22:31:10 +0900 (JST)
Subject: Re: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10] calculate mapped ratio for memory cgroup
In-Reply-To: <20071122084647.485981CEE98@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20071122084647.485981CEE98@siro.lan>
 <20071122174015.c5ef61ae.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Ah, This is what I do now.
>> ==
>> +/*
>> + * Calculate mapped_ratio under memory controller. This will be used in
>> + * vmscan.c for deteremining we have to reclaim mapped pages.
>> + */
>> +int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
>> +{
>> +       long total, rss;
>> +
>> +       /*
>> +        * usage is recorded in bytes. But, here, we assume the number of
>> +        * physical pages can be represented by "long" on any arch.
>> +        */
>> +       total = (long) (mem->res.usage >> PAGE_SHIFT);
>> +       rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
>> +       return (int)((rss * 100L) / total);
>> +}
>> ==
>> 
>> maybe works well.
>> 
>> -Kame
>
>i meant that "/ total" can cause a division-by-zero exception.
>
ouch, ok, will fix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

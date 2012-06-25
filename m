Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3836A6B0307
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 00:26:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 30FFF3EE0BC
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:26:48 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B4E45DE55
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:26:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE7945DE50
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:26:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE641E18007
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:26:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76CB21DB803E
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:26:47 +0900 (JST)
Message-ID: <4FE7E7FA.80702@jp.fujitsu.com>
Date: Mon, 25 Jun 2012 13:24:26 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] memcg: replace unsigned long by u64 to avoid overflow
References: <1340432134-5178-1-git-send-email-liwp.linux@gmail.com> <20120623081514.GJ27816@cmpxchg.org> <20120623090339.GA6184@kernel> <20120623092654.GL27816@cmpxchg.org>
In-Reply-To: <20120623092654.GL27816@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

(2012/06/23 18:26), Johannes Weiner wrote:
> On Sat, Jun 23, 2012 at 05:03:39PM +0800, Wanpeng Li wrote:
>> On Sat, Jun 23, 2012 at 10:15:14AM +0200, Johannes Weiner wrote:
>>> On Sat, Jun 23, 2012 at 02:15:34PM +0800, Wanpeng Li wrote:
>>>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>>>
>>>> Since the return value variable in mem_cgroup_zone_nr_lru_pages and
>>>> mem_cgroup_node_nr_lru_pages functions are u64, so replace the return
>>>> value of funtions by u64 to avoid overflow.
>>>
>>> I wonder what 16 TB of memory must think running on a 32-bit kernel...
>>> "What is this, an address space for ants?"
>>
>> Hi Johannes,
>>
>> You mean change all u64 in memcg to unsigned long? or something I
>> miss....
>
> Not _all_ of them, we have some that count bytes.  But those counting
> pages should probably be ulong, yes.
>
> I think Kame added the ones that you wanted to adjust the surroundings
> for in particular, so let's ask him.  Kame?
>

I've been using 'unsigned long' for the number of pages and 'u64' for the number of
bytes. I think it's enough and it should be. I don't have any reason to use u64 for
the number of pages on 32bit archs.
If 'bytes' are handled by 'unsigned long', please fix it.

BTW, zone_page_state()::/include/linux/vmstat.h returns 'unsigned long'.
If you want to change this in memcg, please change zone's ones first.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

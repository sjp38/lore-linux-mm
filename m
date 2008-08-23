From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <1409530.1219451890296.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 23 Aug 2008 09:38:10 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 1/14] memcg: unlimted root cgroup
In-Reply-To: <48AF42DC.7020705@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48AF42DC.7020705@linux.vnet.ibm.com>
 <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203025.eb4b2ec3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>KAMEZAWA Hiroyuki wrote:
>> Make root cgroup of memory resource controller to have no limit.
>> 
>> By this, users cannot set limit to root group. This is for making root cgro
up
>> as a kind of trash-can.
>> 
>> For accounting pages which has no owner, which are created by force_empty,
>> we need some cgroup with no_limit. A patch for rewriting force_empty will
>> will follow this one.
>> 
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> 
>> ---
>>  Documentation/controllers/memory.txt |    4 ++++
>>  mm/memcontrol.c                      |   12 ++++++++++++
>>  2 files changed, 16 insertions(+)
>> 
>> Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
>> ===================================================================
>> --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
>> +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
>> @@ -133,6 +133,10 @@ struct mem_cgroup {
>>  	 * statistics.
>>  	 */
>>  	struct mem_cgroup_stat stat;
>> +	/*
>> +	 * special flags.
>> +	 */
>> +	int	no_limit;
>
>Is this a generic implementation to support no limits? If not, why not store 
the
>root memory controller pointer and see if someone is trying to set a limit on
 that?
>
Just because I designed this for supporting trash-box and changed my mind..
Sorry. If pointer comparison is better, I'll do that.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

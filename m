From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <6333287.1195036296158.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Nov 2007 19:31:36 +0900 (JST)
Subject: Re: Re: [RFC][ for -mm] memory controller enhancements for NUMA [1/10] record nid/zid on page_cgroup
In-Reply-To: <20071114092243.9331F1CD66B@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20071114092243.9331F1CD66B@siro.lan>
 <20071114174131.cf7c4aa6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

>> Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
>> ===================================================================
>> --- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
>> +++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
>> @@ -131,6 +131,8 @@ struct page_cgroup {
>>  	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
>>  					/* mapped and cached states     */
>>  	int	 flags;
>> +	short	nid;
>> +	short	zid;

>are they worth to be cached?
>can't you use page_zonenum(pc->page)?
>
Maybe I can. I'll drop this and see what the whole code looks like.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

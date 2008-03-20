From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <20398498.1206029708926.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 21 Mar 2008 01:15:08 +0900 (JST)
Subject: Re: Re: Re: Re: [PATCH 7/7] memcg: freeing page_cgroup at suitable chance
In-Reply-To: <1206029390.8514.403.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1206029390.8514.403.camel@twins>
 <22163671.1206024572593.kamezawa.hiroyu@jp.fujitsu.com>
	 <1205999706.8514.394.camel@twins>
	 <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080314192253.edb38762.kamezawa.hiroyu@jp.fujitsu.com>
	 <1205962399.6437.30.camel@lappy>
	 <20080320140703.935073df.kamezawa.hiroyu@jp.fujitsu.com>
	 <2248236.1206029072224.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

>> When we free entries of [pfn, pfn + 1 << order), [pfn, pfn + 1 << order)
>> is in freelist and we have zone->lock. Lookup against [pfn, pfn + 1 << orde
r) 
>> cannot happen against freed pages.
>> Then, looking up and freeing an idx cannot happen at the same time.
>> 
>> radix_tree_lookup() can look up wrong entry in this case ?
> 
>You're right, my bad.
>
your text was very much help for understanding my own codes again...
I'll add enough texts. It seems this use of radix-tree is tricky.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

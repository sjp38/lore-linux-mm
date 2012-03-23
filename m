Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 9CF1F6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:02:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2EE5D3EE0C0
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:02:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08C9945DEB5
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:02:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E390045DE9E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:02:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6E881DB8040
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:02:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C0331DB803B
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:02:19 +0900 (JST)
Message-ID: <4F6C3BB2.6090108@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 18:00:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: change behavior of moving charges at task move
References: <4F69A4C4.4080602@jp.fujitsu.com> <20120322143610.e4df49c9.akpm@linux-foundation.org> <4F6BC166.80407@jp.fujitsu.com> <20120322173000.f078a43f.akpm@linux-foundation.org> <4F6BC94C.80301@jp.fujitsu.com> <20120323085301.GA1739@cmpxchg.org>
In-Reply-To: <20120323085301.GA1739@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

(2012/03/23 17:53), Johannes Weiner wrote:

> On Fri, Mar 23, 2012 at 09:52:28AM +0900, KAMEZAWA Hiroyuki wrote:
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index b2ee6df..ca8b3a1 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5147,7 +5147,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>>  		return NULL;
>>  	if (PageAnon(page)) {
>>  		/* we don't move shared anon */
>> -		if (!move_anon() || page_mapcount(page) > 2)
>> +		if (!move_anon())
>>  			return NULL;
>>  	} else if (!move_file())
>>  		/* we ignore mapcount for file pages */
>> @@ -5158,26 +5158,32 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>>  	return page;
>>  }
>>  
>> +#ifdef CONFFIG_SWAP
> 
> That will probably disable it for good :)
> 


Thank you for your good eyes.. I feel I can't trust my eyes ;(


==

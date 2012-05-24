Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E19706B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 04:31:24 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D3AF83EE0B5
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:31:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6DB045DE4E
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:31:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DBFF45DD74
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:31:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B4B1DB8038
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:31:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 494511DB803C
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:31:22 +0900 (JST)
Message-ID: <4FBDF14F.9020602@jp.fujitsu.com>
Date: Thu, 24 May 2012 17:29:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg/hugetlb: Add failcnt support for hugetlb extension
References: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120523161750.f0e22c5b.akpm@linux-foundation.org> <87likiyyxr.fsf@skywalker.in.ibm.com> <20120523221655.a067710b.akpm@linux-foundation.org>
In-Reply-To: <20120523221655.a067710b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz

(2012/05/24 14:16), Andrew Morton wrote:

> On Thu, 24 May 2012 10:10:00 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
>> Andrew Morton <akpm@linux-foundation.org> writes:
>>
>>> On Tue, 22 May 2012 17:13:11 +0530
>>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>
>>>> Expose the failcnt details to userspace similar to memory and memsw.
>>>
>>> Why?
>>>
>>
>> to help us find whether there was an allocation failure due to HugeTLB
>> limit. 
> 
> How are we to know that is that useful enough to justify expanding the
> kernel API?
> 
> Yes, regular memcg has it, but that isn't a reason.  Do we know that
> people are using that?  That it is useful?
> 
> Also, "cnt" is not a word.  It should be "failcount" or, even better,
> "failure_count".  Or, smarter, "failures".  But we screwed that up a
> long time ago and can't fix it.

It has been there since the first commit of memcg...before I joined.

I sometimes use failcnt to confirm whether an application/benchmark hits
the limit and memory reclaim run by limit or not.

With hugetlb, it has no memory reclaim...'allocation failure by limit'
is informed as -ENOSPC to applications. It seems there 3 reasons of -ENOSPC.
memcg-limit and page-allocation-failure and failure in subpool_get_pages().

I think failcnt may be useful because users may want to know the cause of -ENOSPC
after application exits by seeing -ENOSPC. If failcnt > 0, he will tweak the limit
or check application size. Of course, someone may be able to think of other UI.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

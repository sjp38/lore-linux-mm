Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E94D6B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:40:05 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id o5B5Zc8P031845
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:35:38 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B5dMfT1527858
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:39:22 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B5dMXO024752
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:39:22 +1000
Message-ID: <4C11CC08.9080503@in.ibm.com>
Date: Fri, 11 Jun 2010 11:09:20 +0530
From: Sachin Sant <sachinp@in.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.35-rc2 : OOPS with LTP memcg regression test run.
References: <4C0BB98E.9030101@in.ibm.com> <201006102200.57617.maciej.rutecki@gmail.com> <20100611103509.520671b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100611103509.520671b2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: maciej.rutecki@gmail.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 10 Jun 2010 22:00:57 +0200
> Maciej Rutecki <maciej.rutecki@gmail.com> wrote:
>
>   
>> I created a Bugzilla entry at 
>> https://bugzilla.kernel.org/show_bug.cgi?id=16178
>> for your bug report, please add your address to the CC list in there, thanks!
>>
>>     
>
> Hmm... It seems a panic in SLUB or SLAB.
> Is .config available ?
>   
I think the root cause for this problem was same as the one
mentioned in this thread (Bug kmalloc-4096 : Poison overwritten)

http://marc.info/?l=linux-kernel&m=127586004308747&w=2 <http://marc.info/?l=linux-kernel&m=127586004308747&w=2>

I verified that the problem goes away after applying the commit 386f40c.

Thanks
-Sachin 


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

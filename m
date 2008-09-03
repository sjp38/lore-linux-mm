Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m837UAtY013655
	for <linux-mm@kvack.org>; Wed, 3 Sep 2008 17:30:10 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m837VHG83842276
	for <linux-mm@kvack.org>; Wed, 3 Sep 2008 17:31:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m837VHio007361
	for <linux-mm@kvack.org>; Wed, 3 Sep 2008 17:31:17 +1000
Message-ID: <48BE3D43.7090903@linux.vnet.ibm.com>
Date: Wed, 03 Sep 2008 13:01:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <200809011656.45190.nickpiggin@yahoo.com.au> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809011743.42658.nickpiggin@yahoo.com.au> <48BD0641.4040705@linux.vnet.ibm.com> <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com> <48BD0E4A.5040502@linux.vnet.ibm.com> <20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com> <48BD119B.8020605@linux.vnet.ibm.com> <20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com> <48BD337E.40001@linux.vnet.ibm.com> <20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Sep 2008 18:07:18 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> I understand your concern and I am not trying to reduce memcg's performance - or
>> add a fancy feature. I am trying to make memcg more friendly for distros. I see
>> your point about the overhead. I just got back my results - I see a 4% overhead
>> with the patches. Let me see if I can rework them for better performance.
>>
> Just an idea, by using atomic_ops page_cgroup patch, you can encode page_cgroup->lock
> to page_cgroup->flags and use bit_spinlock(), I think.
> (my new patch set use bit_spinlock on page_cgroup->flags for avoiding some race.)
> 
> This will save extra 4 bytes.

Exactly the next step I was thinking about (since we already use it, in the
current form). Thanks for the suggestion!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

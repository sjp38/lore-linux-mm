Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 01E6C600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 05:19:43 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB2AJcTt007851
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 15:49:38 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB2AJcJc3100722
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 15:49:38 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB2AJbJE007318
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 21:19:38 +1100
Date: Wed, 2 Dec 2009 15:49:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091202101915.GB3545@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20091126085031.GG2970@balbir.in.ibm.com>
 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E461C.50606@parallels.com>
 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E50B1.20602@parallels.com>
 <20091201073609.GQ2970@balbir.in.ibm.com>
 <4B14F29E.3090400@parallels.com>
 <20091201151431.GV2970@balbir.in.ibm.com>
 <4B163DF7.60305@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B163DF7.60305@parallels.com>
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Pavel Emelyanov <xemul@parallels.com> [2009-12-02 13:14:15]:

> Balbir Singh wrote:
> > * Pavel Emelyanov <xemul@parallels.com> [2009-12-01 13:40:30]:
> > 
> >>> Just to understand the context better, is this really a problem. This
> >>> can occur when we do really run out of memory. The idea of using
> >>> slabcg + memcg together is good, except for our accounting process. I
> >>> can repost percpu counter patches that adds fuzziness along with other
> >>> tricks that Kame has to do batch accounting, that we will need to
> >>> make sure we are able to do with slab allocations as well.
> >>>
> >> I'm not sure I understand you concern. Can you elaborate, please?
> >>
> > 
> > The concern was mostly accounting when memcg + slabcg are integrated
> > into the same framework. res_counters will need new scalability
> > primitives.
> > 
> 
> I see. I think the best we can do here is start with a separate controller.
>

I would think so as well, but setting up independent limits might be a
challenge, how does the user really estimate the amount of kernel
memory needed? This is the same problem that David posted sometime
back. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

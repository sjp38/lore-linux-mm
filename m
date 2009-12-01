Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A5935600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 10:14:41 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB1FEZ0q015753
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 20:44:35 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB1FEZwu3047588
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 20:44:35 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB1FEYjQ019221
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 20:44:35 +0530
Date: Tue, 1 Dec 2009 20:44:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091201151431.GV2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20091126085031.GG2970@balbir.in.ibm.com>
 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E461C.50606@parallels.com>
 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E50B1.20602@parallels.com>
 <20091201073609.GQ2970@balbir.in.ibm.com>
 <4B14F29E.3090400@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B14F29E.3090400@parallels.com>
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Pavel Emelyanov <xemul@parallels.com> [2009-12-01 13:40:30]:

> > Just to understand the context better, is this really a problem. This
> > can occur when we do really run out of memory. The idea of using
> > slabcg + memcg together is good, except for our accounting process. I
> > can repost percpu counter patches that adds fuzziness along with other
> > tricks that Kame has to do batch accounting, that we will need to
> > make sure we are able to do with slab allocations as well.
> > 
> 
> I'm not sure I understand you concern. Can you elaborate, please?
> 

The concern was mostly accounting when memcg + slabcg are integrated
into the same framework. res_counters will need new scalability
primitives.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

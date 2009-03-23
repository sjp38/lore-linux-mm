Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EAB0F6B00C5
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:21:54 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2N9NWL5014969
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:53:32 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N9JlXk4444398
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:49:48 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2N9NFdv024454
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:23:15 +1100
Date: Mon, 23 Mar 2009 14:53:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323092302.GO24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090323153241.6A0F.A69D9226@jp.fujitsu.com> <20090323082441.GL24227@balbir.in.ibm.com> <20090323175127.6A15.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323175127.6A15.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-23 18:12:54]:

> > > Kamezawa-san, This implementation is suck. but I think softlimit concept 
> > > itself isn't suck.
> > 
> > Just because of the reclaim factor? Feel free to improve it
> > iteratively. Like I said to Kamezawa, don't over optimize in the first
> > iteration. Pre-mature optimization is the root of all evil.
> 
> Agreed.
> Then, I nacked premature optimization code everytime.
> 
> 
> > > So, I would suggested discuss this feature based on your 
> > > "memcg softlimit (Another one) v4" patch. I exept I can ack it after few spin.
> > 
> > Kame's implementation sucked quite badly, please see my posted test
> > results. Basic, bare minimum functionality did not work.
> 
> Yes. I see.
> but I think it can be fixed. the basic design of the patch is sane IMHO.
>

I have the following major objections to design

1. The use of lists as a data-structure, it will not scale well.
2. Using zone watermarks to implement global soft limits 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

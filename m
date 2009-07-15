Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D436A6B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 00:55:48 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6F5UrNs025669
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 23:30:53 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6F5WRji223166
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 23:32:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6F5WO5N027346
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 23:32:25 -0600
Date: Wed, 15 Jul 2009 11:02:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
Message-ID: <20090715053222.GH24034@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop> <20090715040811.GF24034@balbir.in.ibm.com> <20090715142736.39AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090715142736.39AA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-07-15 14:28:19]:

> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 18:29:50]:
> > 
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > New Feature: Soft limits for memory resource controller.
> > > 
> > > Here is v9 of the new soft limit implementation. Soft limits is a new feature
> > > for the memory resource controller, something similar has existed in the
> > > group scheduler in the form of shares. The CPU controllers interpretation
> > > of shares is very different though. 
> > >
> > 
> > If there are no objections to these patches, could we pick them up for
> > testing in mmotm. 
> 
> Sorry, I haven't review this patch series. please give me few days.
>

Sure, could you see if the reclaim bits are better now. 

-- 
        Thanks,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

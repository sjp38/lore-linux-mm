Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C51D06B00AF
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:24:02 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2N8OsM3006739
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:54:54 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N8LQmx1786040
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:51:26 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2N8OsqP019775
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:54:54 +0530
Date: Mon, 23 Mar 2009 13:54:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323082441.GL24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com> <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com> <20090323153241.6A0F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323153241.6A0F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-23 15:35:50]:

> > On Mon, 23 Mar 2009 15:12:45 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 23 Mar 2009 10:52:47 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > I have one large swap partition, so I could not test the partial-swap
> > > > scenario.
> > > > 
> > > plz go ahead as you like, Seems no landing point now and I'd like to see
> > > what I can, later. I'll send no ACK nor NACK, more.
> > > 
> > But I dislike the whole concept, at all.
> 
> 
> Kamezawa-san, This implementation is suck. but I think softlimit concept 
> itself isn't suck.
> 

Just because of the reclaim factor? Feel free to improve it
iteratively. Like I said to Kamezawa, don't over optimize in the first
iteration. Pre-mature optimization is the root of all evil.

> So, I would suggested discuss this feature based on your 
> "memcg softlimit (Another one) v4" patch. I exept I can ack it after few spin.

Kame's implementation sucked quite badly, please see my posted test
results. Basic, bare minimum functionality did not work.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

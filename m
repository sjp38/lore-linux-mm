Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC886B00B5
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:34:16 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2N8ZJiL021624
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:35:19 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N8ZatG1138942
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:35:36 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2N8ZI9G021885
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:35:19 +1100
Date: Mon, 23 Mar 2009 14:05:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323083506.GN24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com> <20090323052247.GJ24227@balbir.in.ibm.com> <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com> <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 15:17:03]:

> On Mon, 23 Mar 2009 15:12:45 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 23 Mar 2009 10:52:47 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > I have one large swap partition, so I could not test the partial-swap
> > > scenario.
> > > 
> > plz go ahead as you like, Seems no landing point now and I'd like to see
> > what I can, later. I'll send no ACK nor NACK, more.
> > 
> But I dislike the whole concept, at all.
>

Kame, if you dislike it please don't enable
memory.soft_limit_in_bytes. After having sent several revisions of
your own patchset and helping me with review of several revisions, your
sudden dislike comes as a surprise.

Please NOTE: I am not saying we'll never see any of the reclaim
changes you are suggesting, all I am saying is lets do enough test to
prove it is needed. Lets get the functionality right and then optimize
if we have to.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

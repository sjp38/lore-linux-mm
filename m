Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AF1A6B00AB
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 01:36:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N6ZpXx018950
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 15:35:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EF1545DD79
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:35:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C3D045DD78
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:35:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5575FE08003
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:35:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F20121DB8013
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:35:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
In-Reply-To: <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com> <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090323153241.6A0F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 15:35:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

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


Kamezawa-san, This implementation is suck. but I think softlimit concept 
itself isn't suck.

So, I would suggested discuss this feature based on your 
"memcg softlimit (Another one) v4" patch. I exept I can ack it after few spin.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

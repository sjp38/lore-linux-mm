Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1F0286B00A7
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 01:15:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N6EDpf005897
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 15:14:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D02B945DD87
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:14:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D8F345DD83
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:14:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0253CE08003
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:14:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E1EF1DB8042
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:14:11 +0900 (JST)
Date: Mon, 23 Mar 2009 15:12:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323052247.GJ24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323052247.GJ24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 10:52:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> I have one large swap partition, so I could not test the partial-swap
> scenario.
> 
plz go ahead as you like, Seems no landing point now and I'd like to see
what I can, later. I'll send no ACK nor NACK, more.

But please get ack from someone resposible for glorbal memory reclaim.
Especially for hooks in try_to_free_pages().

And please make it clear in documentation that 
 - Depends on the system but this may increase the usage of swap.
 - Depends on the system but this may not work as the user expected as hard-limit.

Considering corner cases, this is a very complicated/usage-is-difficult feature.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

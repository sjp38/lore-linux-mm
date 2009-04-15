Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ABBC05F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 00:14:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F4Ed9Y008515
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 13:14:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 230E045DE57
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:14:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 028E945DE51
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:14:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD8B81DB803E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:14:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9432C1DB803A
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:14:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Add file RSS accounting to the memory resource controller
In-Reply-To: <20090414180706.GQ7082@balbir.in.ibm.com>
References: <20090414180706.GQ7082@balbir.in.ibm.com>
Message-Id: <20090415131348.AC43.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 13:14:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> We currently don't track file RSS, the RSS we report is actually anon RSS.
> All the file mapped pages, come in through the page cache and get accounted
> there. This patch adds support for accounting file RSS pages. It should
> 
> 1. Help improve the metrics reported by the memory resource controller
> 2. Will form the basis for a future shared memory accounting heuristic
>    that has been proposed by Kamezawa.

It seems impressive feature although I haven't review it.
I'll review this later.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

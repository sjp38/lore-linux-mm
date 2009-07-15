Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C11906B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 00:51:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6F5SLpC016159
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Jul 2009 14:28:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5369045DE51
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 14:28:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 304D845DE4F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 14:28:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08190E08003
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 14:28:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B56C41DB803B
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 14:28:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
In-Reply-To: <20090715040811.GF24034@balbir.in.ibm.com>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop> <20090715040811.GF24034@balbir.in.ibm.com>
Message-Id: <20090715142736.39AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Jul 2009 14:28:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 18:29:50]:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > New Feature: Soft limits for memory resource controller.
> > 
> > Here is v9 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. The CPU controllers interpretation
> > of shares is very different though. 
> >
> 
> If there are no objections to these patches, could we pick them up for
> testing in mmotm. 

Sorry, I haven't review this patch series. please give me few days.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

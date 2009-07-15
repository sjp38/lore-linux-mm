Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 89E4C6B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 23:59:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6F4ZS0A025649
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Jul 2009 13:35:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BB5145DE58
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:35:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F05E145DE4F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:35:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D94491DB805B
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:35:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B5621DB8043
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:35:27 +0900 (JST)
Date: Wed, 15 Jul 2009 13:33:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
Message-Id: <20090715133324.e4683ef2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090715040811.GF24034@balbir.in.ibm.com>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
	<20090715040811.GF24034@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 09:38:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

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
> 

If any, will be fixed up in mmotm. About behavior, I don't have more things
than I've said. (dealying kswapd is not very good.)

But plz discuss with Vladislav Buzov about implementation details of [2..3/5].
==
[PATCH 1/2] Resource usage threshold notification addition to res_counter (v3)

It seems there are multiple functionalities you can shere with them.

 - hierarchical threshold check
 - callback or notify agaisnt threshold.
 etc..

I'm very happy if all messy things around res_counter+hierarchy are sorted out
before diving into melting pot. I hope both of you have nice interfaces and
keep res_counter neat.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

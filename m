Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 37D456B01B5
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOvpQ021763
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB0D545DE50
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A95AD45DE4D
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 804C41DB8038
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E2F71DB803E
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608122740.8f045c78.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com> <20100608122740.8f045c78.akpm@linux-foundation.org>
Message-Id: <20100613201257.6199.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry for the delay.

> On Tue, 8 Jun 2010 11:51:32 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Andrew, are you the maintainer for these fixes or is KOSAKI?
> 
> I am, thanks.  Kosaki-san, you're making this harder than it should be.
> Please either ack David's patches or promptly work with him on
> finalising them.

Thanks, Andrew, David. I agree with you. I don't find any end users harm
and regressions in latest David's patch series. So, I'm glad to join his work.

Unfortunatelly, I don't have enough time now. then, I expect my next review
is not quite soon. but I'll promise I'll do.

thanks.


> 
> I realise that you have additional oom-killer patches but it's too
> complex to try to work on two patch series concurrently.  So let's
> concentrate on get David's work sorted out and merged and then please
> rebase yours on the result.
> 
> I certainly don't have the time or inclination to go through two
> patchsets and work out what the similarities and differences are so
> I'll be concentrating on David's ones first.  The order in which we
> do this doesn't really matter.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

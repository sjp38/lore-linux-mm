Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7BC6B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 18:35:18 -0400 (EDT)
Date: Fri, 2 Jul 2010 15:35:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
Message-Id: <20100702153508.fda82eb9.akpm@linux-foundation.org>
In-Reply-To: <20100613201257.6199.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com>
	<20100608122740.8f045c78.akpm@linux-foundation.org>
	<20100613201257.6199.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jun 2010 20:24:55 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Sorry for the delay.
> 
> > On Tue, 8 Jun 2010 11:51:32 -0700 (PDT)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > Andrew, are you the maintainer for these fixes or is KOSAKI?
> > 
> > I am, thanks.  Kosaki-san, you're making this harder than it should be.
> > Please either ack David's patches or promptly work with him on
> > finalising them.
> 
> Thanks, Andrew, David. I agree with you. I don't find any end users harm
> and regressions in latest David's patch series. So, I'm glad to join his work.

whew ;)

> Unfortunatelly, I don't have enough time now. then, I expect my next review
> is not quite soon. but I'll promise I'll do.

So where do we go from here?  I have about 12,000 oom-killer related
emails saved up in my todo folder, ready for me to read next time I
have an oom-killer session.

What would happen if I just deleted them all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

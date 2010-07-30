Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F191C6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 21:38:34 -0400 (EDT)
Date: Thu, 29 Jul 2010 18:38:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100729183809.ca4ed8be.akpm@linux-foundation.org>
In-Reply-To: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1007170307110.8730@chino.kir.corp.google.com>
	<20100729160822.cd910c1b.akpm@linux-foundation.org>
	<20100730091125.4AC3.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010 09:12:26 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > 
> > > This a complete rewrite of the oom killer's badness() heuristic 
> > 
> > Any comments here, or are we ready to proceed?
> > 
> > Gimme those acked-bys, reviewed-bys and tested-bys, please!
> 
> If he continue to resend all of rewrite patch, I continue to refuse them.
> I explained it multi times.

There are about 1000 emails on this topic.  Please briefly explain it again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

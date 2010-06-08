Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 100176B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:12:20 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:12:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it
 has been killed
Message-Id: <20100608131211.e769e3a1.akpm@linux-foundation.org>
In-Reply-To: <20100608203216.765D.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com>
	<20100608203216.765D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 20:41:57 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > +
> >  	if (sysctl_panic_on_oom == 2) {
> >  		dump_header(NULL, gfp_mask, order, NULL);
> >  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
> 
> Sorry, I had found this patch works incorrect. I don't pulled.

Saying "it doesn't work and I'm not telling you why" is unhelpful.  In
fact it's the opposite of helpful because it blocks merging of the fix
and doesn't give us any way to move forward.

So what can I do?  Hard.

What I shall do is to merge the patch in the hope that someone else will
discover the undescribed problem and we will fix it then.  That's very
inefficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

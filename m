Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 81D526B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:53:01 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:52:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 01/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
Message-Id: <20100608165253.fc4871cb.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006081639420.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com>
	<20100608123320.11e501a4.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1006081639420.19582@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 16:40:07 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > 
> > Applied, thanks.  A minor bugfix.
> > 
> 
> Thanks!  I didn't see it added to -mm, though,

doh.

<adds it>

> so I'll assume it's being 
> queued for 2.6.35-rc3 instead.

Linus is being all strict - "regression and oops fixes only", and I
don't think a fix of this magnitude passes the test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

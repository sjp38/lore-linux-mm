Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 17A0D6B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 17:27:25 -0400 (EDT)
Date: Tue, 8 Jun 2010 14:27:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 13/18] oom: remove special handling for pagefault ooms
Message-Id: <20100608142719.02d4f61a.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061526120.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061526120.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:44 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It is possible to remove the special pagefault oom handler

It'd be useful to describe what services that handler provides and to
then describe how these services are retained in the new version.

> by simply oom
> locking all system zones and then calling directly into out_of_memory().
> 
> All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
> parallel oom killing in progress that will lead to eventual memory freeing
> so it's not necessary to needlessly kill another task.

Should that have read "otherwise if there is"?

(the code comments actually clarify all this)

>  The context in
> which the pagefault is allocating memory is unknown to the oom killer, so
> this is done on a system-wide level.
> 
> If a task has already been oom killed and hasn't fully exited yet, this
> will be a no-op since select_bad_process() recognizes tasks across the
> system with TIF_MEMDIE set.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

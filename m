Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0D7576B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 16:24:24 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so12582266pbb.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 13:24:24 -0700 (PDT)
Date: Tue, 19 Jun 2012 13:24:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
In-Reply-To: <20120619135551.GA24542@redhat.com>
Message-ID: <alpine.DEB.2.00.1206191323470.17985@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
 <20120619135551.GA24542@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 19 Jun 2012, Oleg Nesterov wrote:

> 	if (killed && !(current->flags & PF_EXITING))
> 		schedule_timeout_killable(1);
> 
> makes more sense?
> 
> If fatal_signal_pending() == T then schedule_timeout_killable()
> is nop, but unline uninterruptible_ it can be SIGKILL'ed.
> 

Ok, that's certainly cleaner.  I'll post a v3, thanks for the suggestion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

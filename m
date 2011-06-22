Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28BED90015D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:29:43 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p5M3Tchu026419
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:29:38 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by hpaq12.eem.corp.google.com with ESMTP id p5M3TZTo031922
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:29:37 -0700
Received: by pwi9 with SMTP id 9so452677pwi.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:29:35 -0700 (PDT)
Date: Tue, 21 Jun 2011 20:29:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP
 configurable
In-Reply-To: <4E015C36.2050005@redhat.com>
Message-ID: <alpine.DEB.2.00.1106212024210.8712@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com> <4E015C36.2050005@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 22 Jun 2011, Cong Wang wrote:

> > I like the printk that notifies users why THP was disabled because it
> > could potentially be a source of confusion (and fixing the existing typos
> > in hugepage_init() would also be good).  However, I disagree that we need
> > to have this as a config option: you either want the feature for your
> > systems or you don't.  Perhaps add a "transparent_hugepage=force" option
> > that will act as "always" but also force it to be enabled in all
> > scenarios, even without X86_FEATURE_PSE, that will override all the logic
> > that thinks it knows better?
> 
> I think that is overkill, because we can still enable THP via /sys
> for small systems.
> 

That was already possible before your patch, your patch is only 
introducing a configuration value that determines whether it is enabled by 
default or not.  I was proposing a very simple interface that would 
override all logic that could be used instead when you know for certain 
that you want THP enabled by default regardless of its logic.  That's 
extendable because it can bypass any additional code added later to 
determine when it should default on or off without adding additional 
config options.  I wouldn't support an additional command line option, but 
rather only an additional option for transparent_hugepage=.

Either way, this patch isn't needed since it has no benefit over doing it 
through an init script.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

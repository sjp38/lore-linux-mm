Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9436B01F6
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:23:21 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p5M1NCoe012381
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:23:12 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by wpaz29.hot.corp.google.com with ESMTP id p5M1NAc0027176
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:23:11 -0700
Received: by pwi16 with SMTP id 16so344451pwi.40
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:23:10 -0700 (PDT)
Date: Tue, 21 Jun 2011 18:23:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP
 configurable
In-Reply-To: <1308643849-3325-2-git-send-email-amwang@redhat.com>
Message-ID: <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 21 Jun 2011, Amerigo Wang wrote:

> Don't hard-code 512M as the threshold in kernel, make it configruable,
> and set 512M by default.
> 
> And print info when THP is disabled automatically on small systems.
> 
> V2: Add more description in help messages, correct some typos,
> print the mini threshold too.
> 

I like the printk that notifies users why THP was disabled because it 
could potentially be a source of confusion (and fixing the existing typos 
in hugepage_init() would also be good).  However, I disagree that we need 
to have this as a config option: you either want the feature for your 
systems or you don't.  Perhaps add a "transparent_hugepage=force" option 
that will act as "always" but also force it to be enabled in all 
scenarios, even without X86_FEATURE_PSE, that will override all the logic 
that thinks it knows better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

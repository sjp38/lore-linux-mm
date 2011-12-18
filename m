Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6C8916B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 17:45:39 -0500 (EST)
Received: by iacb35 with SMTP id b35so7410322iac.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 14:45:38 -0800 (PST)
Date: Sun, 18 Dec 2011 14:45:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy.c: use enum value MPOL_REBIND_ONCE instead
 of 0 in mpol_rebind_policy
In-Reply-To: <4EEC9D54.502@gmail.com>
Message-ID: <alpine.DEB.2.00.1112181444530.1364@chino.kir.corp.google.com>
References: <4EE8A461.2080406@gmail.com> <alpine.DEB.2.00.1112141840550.27595@chino.kir.corp.google.com> <4EEC9D54.502@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Sat, 17 Dec 2011, Wang Sheng-Hui wrote:

> > Tip: when proposing patches, it's helpful to run scripts/get_maintainer.pl 
> > on your patch file from git to determine who should be cc'd on the email.
> 
> Thanks for your tip.
> I have tried the script with option -f, and only get the mm, kernel mailing
> lists, no specific maintainer provided. So here I just posted the patch to 
> these 2 lists.
> 

$ ./scripts/get_maintainer.pl -f mm/mempolicy.c
Andrew Morton <akpm@linux-foundation.org> (commit_signer:19/23=83%)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (commit_signer:8/23=35%)
Stephen Wilson <wilsons@start.ca> (commit_signer:6/23=26%)
Andrea Arcangeli <aarcange@redhat.com> (commit_signer:5/23=22%)
Johannes Weiner <hannes@cmpxchg.org> (commit_signer:3/23=13%)
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)

All of those people should be cc'd on patches touching mm/mempolicy.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

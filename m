Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEC790015D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:24:22 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p5M3OJE5010725
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:24:19 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq11.eem.corp.google.com with ESMTP id p5M3OGkD031943
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:24:17 -0700
Received: by pwj1 with SMTP id 1so354746pwj.9
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:24:15 -0700 (PDT)
Date: Tue, 21 Jun 2011 20:24:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by
 transparent_hugepage=0
In-Reply-To: <4E015CB8.1010300@redhat.com>
Message-ID: <alpine.DEB.2.00.1106212010520.8712@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211814250.5205@chino.kir.corp.google.com> <4E015CB8.1010300@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, 22 Jun 2011, Cong Wang wrote:

> > > Introduce "transparent_hugepage=0" to totally disable THP.
> > > "transparent_hugepage=never" means setting THP to be partially
> > > disabled, we need a new way to totally disable it.
> > > 
> > 
> > Why can't you just compile it off so you never even compile
> > mm/huge_memory.c in the first place and save the space in the kernel image
> > as well?  Having the interface available to enable the feature at runtime
> > is worth the savings this patch provides, in my opinion.
> 
> https://lkml.org/lkml/2011/6/20/506
> 

If you're proposing a patch for a specific purpose, it's appropriate to 
include that in the changelog.

But now that I know what you're proposing this for, it's an easy NACK: 
transparent_hugepage=0 has no significant benefit over 
transparent_hugepage=never for kdump because the memory savings is 
negligible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E994A90015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 02:23:57 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p5M6Nra0028501
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:23:53 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz24.hot.corp.google.com with ESMTP id p5M6NgF6011970
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:23:51 -0700
Received: by pzk9 with SMTP id 9so431317pzk.33
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 23:23:49 -0700 (PDT)
Date: Tue, 21 Jun 2011 23:23:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by
 transparent_hugepage=0
In-Reply-To: <4E01816A.3040309@redhat.com>
Message-ID: <alpine.DEB.2.00.1106212322510.14693@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211814250.5205@chino.kir.corp.google.com> <4E015CB8.1010300@redhat.com> <alpine.DEB.2.00.1106212010520.8712@chino.kir.corp.google.com> <4E01816A.3040309@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, 22 Jun 2011, Cong Wang wrote:

> > If you're proposing a patch for a specific purpose, it's appropriate to
> > include that in the changelog.
> 
> Sorry, I can't put everything you don't see into the changelog.
> 

As far as changelogs go, yes, we can demand that.

> > 
> > But now that I know what you're proposing this for, it's an easy NACK:
> > transparent_hugepage=0 has no significant benefit over
> > transparent_hugepage=never for kdump because the memory savings is
> > negligible.
> 
> I hate to repeat things, sorry, please go for the other thread where I
> replied to Andrea.
> 

All of this needs to be in the changelog if you want your patches to even 
be considered, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

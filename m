Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CFE6E6B01F4
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:16:45 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p5M1Gft3002849
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:16:41 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by wpaz29.hot.corp.google.com with ESMTP id p5M1GbgG021594
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:16:40 -0700
Received: by pvc12 with SMTP id 12so245248pvc.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:16:37 -0700 (PDT)
Date: Tue, 21 Jun 2011 18:16:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by
 transparent_hugepage=0
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Message-ID: <alpine.DEB.2.00.1106211814250.5205@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue, 21 Jun 2011, Amerigo Wang wrote:

> Introduce "transparent_hugepage=0" to totally disable THP.
> "transparent_hugepage=never" means setting THP to be partially
> disabled, we need a new way to totally disable it.
> 

Why can't you just compile it off so you never even compile 
mm/huge_memory.c in the first place and save the space in the kernel image 
as well?  Having the interface available to enable the feature at runtime 
is worth the savings this patch provides, in my opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

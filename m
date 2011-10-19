Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6356B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 20:56:42 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p9J0ufH8024147
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:56:41 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz17.hot.corp.google.com with ESMTP id p9J0nN49027997
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:56:40 -0700
Received: by pzk4 with SMTP id 4so3772918pzk.10
        for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:56:37 -0700 (PDT)
Date: Tue, 18 Oct 2011 17:56:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: munlock use mapcount to avoid terrible overhead
In-Reply-To: <20111018171453.53075590.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1110181752440.4283@sister.anvils>
References: <alpine.LSU.2.00.1110181700400.3361@sister.anvils> <20111018171453.53075590.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Oct 2011, Andrew Morton wrote:
> On Tue, 18 Oct 2011 17:02:56 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > A process spent 30 minutes exiting, just munlocking the pages of a large
> > anonymous area that had been alternately mprotected into page-sized vmas:
> > for every single page there's an anon_vma walk through all the other
> > little vmas to find the right one.
> 
> And how long did the test case take with the patch applied?

5 seconds in the case tried; but the issue is quadratic,
so you can make the improvement look arbitrarily good.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

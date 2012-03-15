Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8A75C6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 18:30:05 -0400 (EDT)
Date: Thu, 15 Mar 2012 15:30:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-Id: <20120315153001.fd97d3fa.akpm@linux-foundation.org>
In-Reply-To: <20120315174128.GS6329@redhat.com>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
	<20120315171627.GB22255@redhat.com>
	<20120315174128.GS6329@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, stable@kernel.org

On Thu, 15 Mar 2012 18:41:28 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> >  > Reported-by: Ulrich Obergfell <uobergfe@redhat.com>
> >  > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Should probably go to stable too ? How far back does this bug go ?
> 
> This goes back to 2.6.38 (included). After it gets a bit more of
> testing and reviews it'll be ok for stable yes.

I'm thinking that we merge it into 3.4-rc1, marked for backporting. 
That will give us a bit of time to shake it down in mainline before it
turns up in stable trees.  So 3.3 itself will still have the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

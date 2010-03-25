Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C1CDC6B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 10:36:13 -0400 (EDT)
Date: Thu, 25 Mar 2010 09:35:05 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
In-Reply-To: <20100325092131.GK2024@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003250933480.2670@router.home>
References: <20100325083235.GF2024@csn.ul.ie> <20100325180221.e1d9bae7.kamezawa.hiroyu@jp.fujitsu.com> <20100325180726.6C89.A69D9226@jp.fujitsu.com> <20100325092131.GK2024@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010, Mel Gorman wrote:

> Christoph is opposed to removing it because of cache-hotness issues more
> so than use-after-free concerns. The refcount is needed with or without
> SLAB_DESTROY_BY_RCU.

The issue is only performance. If we can preserve the cache hotness in a
different way (or do things in a completely different manner) then its
fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

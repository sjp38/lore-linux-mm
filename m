Message-ID: <48F77430.80001@redhat.com>
Date: Thu, 16 Oct 2008 13:04:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <200810170043.26922.nickpiggin@yahoo.com.au>
In-Reply-To: <200810170043.26922.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> ClearPageReferenced I don't know if it should be cleared like this.
> PageReferenced is more of a bit for the mark_page_accessed state machine,
> rather than the pte_young stuff. Although when unmapping, the latter
> somewhat collapses back to the former, but I don't know if there is a
> very good reason to fiddle with it here.
> 
> Ignoring the young bit in the pte for sequential hint maybe is OK (and
> seems to be effective as per the benchmarks). But I would prefer not to
> merge the PageReferenced parts unless they get their own justification.

Unless we clear the PageReferenced bit, we will still activate
the page - even if its only access came through a sequential
mapping.

Faulting the page into the sequential mapping ends up setting
PageReferenced, IIRC.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 49C636B009D
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:45:20 -0500 (EST)
Message-ID: <4B7EC013.5090704@redhat.com>
Date: Fri, 19 Feb 2010 11:45:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] mm,migration: Do not try to migrate unmapped anonymous
 pages
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1266516162-14154-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/18/2010 01:02 PM, Mel Gorman wrote:
> rmap_walk_anon() was triggering errors in memory compaction that looks like
> use-after-free errors in anon_vma. The problem appears to be that between
> the page being isolated from the LRU and rcu_read_lock() being taken, the
> mapcount of the page dropped to 0 and the anon_vma was freed. This patch
> skips the migration of anon pages that are not mapped by anyone.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

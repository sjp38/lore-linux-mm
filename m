Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 818EF6B007D
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:46:47 -0500 (EST)
Message-ID: <4B7F06A7.2030505@redhat.com>
Date: Fri, 19 Feb 2010 16:46:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/12] Export unusable free space index via /proc/pagetypeinfo
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1266516162-14154-7-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/18/2010 01:02 PM, Mel Gorman wrote:
> Unusuable free space index is a measure of external fragmentation that
> takes the allocation size into account. For the most part, the huge page
> size will be the size of interest but not necessarily so it is exported
> on a per-order and per-zone basis via /proc/unusable_index.
>
> The index is a value between 0 and 1. It can be expressed as a
> percentage by multiplying by 100 as documented in
> Documentation/filesystems/proc.txt.
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

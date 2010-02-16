Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 907E16B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:29:17 -0500 (EST)
Message-ID: <4B7AE3D9.9040504@redhat.com>
Date: Tue, 16 Feb 2010 13:28:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] Export unusable free space index via /proc/pagetypeinfo
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-4-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/12/2010 07:00 AM, Mel Gorman wrote:
> Unusuable free space index is a measure of external fragmentation that
> takes the allocation size into account. For the most part, the huge page
> size will be the size of interest but not necessarily so it is exported
> on a per-order and per-zone basis via /proc/pagetypeinfo.
>
> The index is normally calculated as a value between 0 and 1 which is
> obviously unsuitable within the kernel. Instead, the first three decimal
> places are used as a value between 0 and 1000 for an integer approximation.
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E5916B004D
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 23:09:53 -0500 (EST)
Message-ID: <4B7CBD71.2040709@redhat.com>
Date: Wed, 17 Feb 2010 23:09:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/12] Do not compact within a preferred zone after a
 compaction failure
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-10-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/12/2010 07:00 AM, Mel Gorman wrote:
> The fragmentation index may indicate that a failure it due to external
> fragmentation, a compaction run complete and an allocation failure still
> fail. There are two obvious reasons as to why
>
>    o Page migration cannot move all pages so fragmentation remains
>    o A suitable page may exist but watermarks are not met
>
> In the event of compaction and allocation failure, this patch prevents
> compaction happening for a short interval. It's only recorded on the
> preferred zone but that should be enough coverage. This could have been
> implemented similar to the zonelist_cache but the increased size of the
> zonelist did not appear to be justified.
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

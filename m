Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F8D86B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 12:43:42 -0500 (EST)
Message-ID: <4B7AD92C.6050802@redhat.com>
Date: Tue, 16 Feb 2010 12:43:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
 or memory hot-remove
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/12/2010 07:00 AM, Mel Gorman wrote:
> CONFIG_MIGRATION currently depends on CONFIG_NUMA or on the architecture
> being able to hot-remove memory. The main users of page migration such as
> sys_move_pages(), sys_migrate_pages() and cpuset process migration are
> only beneficial on NUMA so it makes sense.
>
> As memory compaction will operate within a zone and is useful on both NUMA
> and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
> user selects CONFIG_COMPACTION as an option.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter<cl@linux-foundation.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

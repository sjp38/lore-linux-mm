Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E22C06B0113
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:38:02 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:37:20 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
 or memory hot-remove
In-Reply-To: <20100317113205.GC12388@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003171135390.27268@router.home>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-5-git-send-email-mel@csn.ul.ie> <20100317110748.4C94.A69D9226@jp.fujitsu.com> <20100317113205.GC12388@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010, Mel Gorman wrote:

> > If select MIGRATION works, we can remove "depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE"
> > line from config MIGRATION.
> >
>
> I'm not quite getting why this would be an advantage. COMPACTION
> requires MIGRATION but conceivable both NUMA and HOTREMOVE can work
> without it.

Avoids having to add additional CONFIG_XXX on the page migration "depends"
line in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

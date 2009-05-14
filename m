Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2553D6B0062
	for <linux-mm@kvack.org>; Thu, 14 May 2009 15:56:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A63D282C2E4
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:10:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id R2ZsYjXeENWm for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:10:24 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EDCE682C31A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:10:19 -0400 (EDT)
Date: Thu, 14 May 2009 15:57:32 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] vmscan: drop PF_SWAPWRITE from zone_reclaim
In-Reply-To: <20090513120627.587F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905141553160.1381@qirst.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120627.587F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009, KOSAKI Motohiro wrote:

> Subject: [PATCH] vmscan: drop PF_SWAPWRITE from zone_reclaim
>
> PF_SWAPWRITE mean ignore write congestion. (see may_write_to_queue())
>
> foreground reclaim shouldn't ignore it because to write congested device cause
> large IO lantency.
> it isn't better than remote node allocation.

Zone reclaim by default does not perform writes. RECLAIM_WRITE must be set
for that to be effective.

Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

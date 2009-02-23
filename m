Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6545D6B003D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 02:21:11 -0500 (EST)
Received: by fxm10 with SMTP id 10so1551213fxm.14
        for <linux-mm@kvack.org>; Sun, 22 Feb 2009 23:21:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235344649-18265-12-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235344649-18265-12-git-send-email-mel@csn.ul.ie>
Date: Mon, 23 Feb 2009 09:21:09 +0200
Message-ID: <84144f020902222321q12f54ed8wae3865064bb6e43@mail.gmail.com>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> In the best-case scenario, use an inlined version of
> get_page_from_freelist(). This increases the size of the text but avoids
> time spent pushing arguments onto the stack.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

It's not obvious to me why this would be a huge win so I suppose this
patch description could use numbers. Note: we used to do tricks like
these in slab.c but got rid of most of them to reduce kernel text size
which is probably why the patch seems bit backwards to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

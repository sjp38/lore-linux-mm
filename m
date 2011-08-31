Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DFC6A6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 07:13:26 -0400 (EDT)
Date: Wed, 31 Aug 2011 13:13:22 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 1/3] Correct isolate_mode_t bitwise type
Message-ID: <20110831111322.GA17512@redhat.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Sun, Nov 13, 2011 at 01:37:41AM +0900, Minchan Kim wrote:
> [c1e8b0ae8, mm-change-isolate-mode-from-define-to-bitwise-type]
> made a mistake on the bitwise type.
> 
> This patch corrects it.
> 
> CC: Mel Gorman <mgorman@suse.de>
> CC: Johannes Weiner <jweiner@redhat.com>
> CC: Rik van Riel <riel@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

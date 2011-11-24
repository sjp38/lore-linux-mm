Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E2936B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:03:32 -0500 (EST)
Date: Thu, 24 Nov 2011 15:03:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: push isolate search base of compact
 control one pfn ahead
Message-ID: <20111124140327.GP8397@redhat.com>
References: <CAJd=RBCJwyo3dQAYmE3oXBBDMDa5GkePfQ_Sct_YUt5=_1-ovw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBCJwyo3dQAYmE3oXBBDMDa5GkePfQ_Sct_YUt5=_1-ovw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 24, 2011 at 08:38:14PM +0800, Hillf Danton wrote:
> After isolated the current pfn will no longer be scanned and isolated if the
> next round is necessary, so push the isolate_migratepages search base of the
> given compact_control one step ahead.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Actually I did this change in my tree already while playing with
compaction last few days so I didn't actually need to review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 615466B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:52:24 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so5596588wes.9
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 13:52:23 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id d11si10011355wic.34.2014.06.16.13.52.22
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 13:52:22 -0700 (PDT)
Date: Mon, 16 Jun 2014 23:49:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: move invariant bug check out of loop in
 __split_huge_page_map
Message-ID: <20140616204934.GA14208@node.dhcp.inet.fi>
References: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Mon, Jun 16, 2014 at 03:35:48PM -0400, Waiman Long wrote:
> In the __split_huge_page_map() function, the check for
> page_mapcount(page) is invariant within the for loop. Because of the
> fact that the macro is implemented using atomic_read(), the redundant
> check cannot be optimized away by the compiler leading to unnecessary
> read to the page structure.
> 
> This patch move the invariant bug check out of the loop so that it
> will be done only once.

Looks okay, but why? Was you able to measure difference?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

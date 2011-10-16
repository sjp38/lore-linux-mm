Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0BA96B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 12:11:22 -0400 (EDT)
Date: Sun, 16 Oct 2011 12:11:08 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111016161108.GA18257@infradead.org>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org, Anders Ossowicki <aowi@novozymes.com>

Btw, 

Anders Ossowicki reported a very similar soft lockup on 2.6.38 recently,
although without a bug on before.

Here is the pointer: https://lkml.org/lkml/2011/10/11/87

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

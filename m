Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 212186B004A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 08:41:29 -0400 (EDT)
Date: Mon, 23 Apr 2012 13:41:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
Message-ID: <20120423124124.GB3255@suse.de>
References: <20120416141423.GD2359@suse.de>
 <alpine.LSU.2.00.1204161332120.1675@eggly.anvils>
 <20120417122202.GF2359@suse.de>
 <alpine.LSU.2.00.1204172023390.1609@eggly.anvils>
 <20120418152831.GK2359@suse.de>
 <alpine.LSU.2.00.1204181005500.1811@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204181005500.1811@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 18, 2012 at 10:09:24AM -0700, Hugh Dickins wrote:
> > Acked-by: Mel Gorman <mgorman@suse.de>
> > 
> > I've sent a kernel based on this patch to the s390 folk that originally
> > reported the bug. Hopefully they'll test and get back to me in a few
> > days.
> 
> Thanks - I'll leave it at that for the moment, expecting to hear back.
> 

Tests completed successfully confirming that this was certainly a
PageSwapCache issue. Will you resend the patch to Andrew for merging or
will I?

Thanks Hugh.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

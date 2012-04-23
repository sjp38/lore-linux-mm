Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 517AE6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 14:10:07 -0400 (EDT)
Received: by yhr47 with SMTP id 47so8752441yhr.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 11:10:06 -0700 (PDT)
Date: Mon, 23 Apr 2012 11:09:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
In-Reply-To: <20120423124124.GB3255@suse.de>
Message-ID: <alpine.LSU.2.00.1204231106450.23248@eggly.anvils>
References: <20120416141423.GD2359@suse.de> <alpine.LSU.2.00.1204161332120.1675@eggly.anvils> <20120417122202.GF2359@suse.de> <alpine.LSU.2.00.1204172023390.1609@eggly.anvils> <20120418152831.GK2359@suse.de> <alpine.LSU.2.00.1204181005500.1811@eggly.anvils>
 <20120423124124.GB3255@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 23 Apr 2012, Mel Gorman wrote:
> On Wed, Apr 18, 2012 at 10:09:24AM -0700, Hugh Dickins wrote:
> > > Acked-by: Mel Gorman <mgorman@suse.de>
> > > 
> > > I've sent a kernel based on this patch to the s390 folk that originally
> > > reported the bug. Hopefully they'll test and get back to me in a few
> > > days.
> > 
> > Thanks - I'll leave it at that for the moment, expecting to hear back.
> > 
> 
> Tests completed successfully confirming that this was certainly a
> PageSwapCache issue. Will you resend the patch to Andrew for merging or
> will I?
> 
> Thanks Hugh.

Great, thanks Mel: as it's a one-liner, I'll send it straight to Linus now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

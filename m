Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0VJExNZ007705
	for <linux-mm@kvack.org>; Mon, 31 Jan 2005 11:15:00 -0800 (PST)
Message-ID: <41FE84DD.94D4B46B@akamai.com>
Date: Mon, 31 Jan 2005 11:19:57 -0800
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: test_root reorder(Re: [patch] ext2: Apply Jack's ext3 speedups)
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org> <41FAED57.DFCF1D22@akamai.com> <41FAFEF1.B13D59BA@akamai.com> <20050131095148.GB2482@atrey.karlin.mff.cuni.cz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jan Kara wrote:

> > Prasanna Meda wrote:
> >
> > >   - Folded all three root checkings for 3,  5 and 7 into one loop.
> > >   -  Short cut the loop with 3**n < 5 **n < 7**n logic.
> > >   -  Even numbers can be ruled out.
> >
> > Without going to that complicated path, the better performance
> > is achieved with just reordering  of the tests from 3,5,7 to 7,5.3, so
> > that average case becomes better. This is more simpler than
> >  folding  patch.
>   I like a bit more just to reorder the tests (though I agree that your
> joined tests for 3,5,7 are probably faster) - it looks much more
> readable...

Yes, Also reordering is almost same as folding aproach in
experimental  test. So, there is no need of going to that complicated
 path. Just  reorder 7, 5 and 3 and check for evenness.


Thanks,
Prasanna.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

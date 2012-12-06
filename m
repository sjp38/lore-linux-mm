Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4B3AE6B00B8
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:20:23 -0500 (EST)
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h22.telenor.se (Postfix) with ESMTP id 6ABF5E8CAE
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 18:20:21 +0100 (CET)
From: "Henrik Rydberg" <rydberg@euromail.se>
Date: Thu, 6 Dec 2012 18:22:25 +0100
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206172225.GA978@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206161934.GA17258@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

> Still travelling and am not in a position to test this properly :(.
> However, this bug feels very similar to a bug in the migration scanner where
> a pfn_valid check is missed because the start is not aligned.  Henrik, when
> did this start happening? I would be a little surprised if it started between
> 3.6 and 3.7-rcX but maybe it's just easier to hit now for some reason. How
> reproducible is this? Is there anything in particular you do to trigger the
> oops? Does the following patch help any? It's only compile tested I'm afraid.

I managed to trigger the path several times with a small
memory-intensive program, and since I am still here,

    Tested-by: Henrik Rydberg <rydberg@euromail.se>

Thanks!
Henrik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

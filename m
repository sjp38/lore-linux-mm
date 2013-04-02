Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C86576B003C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 19:16:15 -0400 (EDT)
Date: Tue, 2 Apr 2013 19:16:13 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130402231613.GA4946@thunk.org>
References: <20130402142717.GH32241@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130402142717.GH32241@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

I've tried doing some quick timing, and if it is a performance
regression, it's not a recent one --- or I haven't been able to
reproduce what Mel is seeing.  I tried the following commands while
booted into 3.2, 3.8, and 3.9-rc3 kernels:

time git clone ...
rm .git/index ; time git reset

I did this a number of git repo's; including one that was freshly
cloned, and one that had around 3 dozen patches applied via git am (so
there were a bunch of loose objects).  And I tried doing this on an
SSD and a 5400rpm HDD, and I did it with all of the in-memory cache
flushed via "git 3 > /proc/sys/vm/drop_caches".  The worst case was
doing a "time git reset" after deleting the .git/index file after
applying all of Kent Overstreet's recent AIO patches that had been
sent out for review.  It took around 55 seconds, on 3.2, 3.8 and
3.9-rc3.  That is pretty horrible, but for me that's the reason why I
use SSD's.

Mel, how bad is various git commands that you are trying?  Have you
tried using time to get estimates of how long a git clone or other git
operation is taking?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

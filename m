Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8A19C6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:30:10 -0500 (EST)
Date: Tue, 27 Nov 2012 16:29:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121127212911.GR24381@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
 <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Nov 27, 2012 at 12:58:18PM -0800, Linus Torvalds wrote:
> Note that in the meantime, I've also applied (through Andrew) the
> patch that reverts commit c654345924f7 (see commit 82b212f40059
> 'Revert "mm: remove __GFP_NO_KSWAPD"').
> 
> I wonder if that revert may be bogus, and a result of this same issue.
> Maybe that revert should be reverted, and replaced with your patch?

The __GFP_NO_KSWAPD removal woke kswapd for THP reclaim and so it
exposed all these bugs that accumulated in there when higher order
kswapd reclaim was excercised less often.

The revert will hide the problem again, but doesn't make it go away
entirely, so I think we need my fix either way.

Whether you want to put the full THP weight back on the freshly fixed
higher order kswapd code for 3.7 is a different matter :-) At least we
would see quickly if it's still not working correctly...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

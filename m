Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4B5528026B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:54:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so322191wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 01:54:15 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id ju8si1270609wjb.191.2016.09.27.01.54.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 01:54:14 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 1700098E00
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 08:54:14 +0000 (UTC)
Date: Tue, 27 Sep 2016 09:54:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927085412.GD2838@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160927073055.GM2794@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > Also, if those bitlock ops had a different bit that showed contention,
> > we could actually skip *all* of this, and just see that "oh, nobody is
> > waiting on this page anyway, so there's no point in looking up those
> > wait queues". We don't have that many "__wait_on_bit()" users, maybe
> > we could say that the bitlocks do have to haev *two* bits: one for the
> > lock bit itself, and one for "there is contention".
> 
> That would be fairly simple to implement, the difficulty would be
> actually getting a page-flag to use for this. We're running pretty low
> in available bits :/

Simple is relative unless I drastically overcomplicated things and it
wouldn't be the first time. 64-bit only side-steps the page flag issue
as long as we can live with that.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

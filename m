Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 22F696B007E
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:22:27 -0400 (EDT)
Date: Tue, 26 May 2009 15:29:14 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090526132914.GF846@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <4A1BE58A.9060708@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1BE58A.9060708@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 09:50:18PM +0900, Hidehiro Kawai wrote:
> I believe people concerning high reliable system are expecting
> this kind of functionality.
> But I wonder why this patch set (including former MCE improvements
> patches) has not been merged into any subsystem trees yet.


> What is the problem?  Because of the deadlock bug and the ref counter

I hadn't asked for a mm merge for the hwpoison version because
it still needed some work. mce has been ready for some time for
merge, although of course as we do more testing we still
find occasional bugs that are getting fixed.

There was some work recently on fixing problems found in the
hwpoison code during further review (me with Fengguang Wu). 
I'm hoping to do a repost with all the fixes soon
and then it's a mm candidate and hopefully ready for merge really soon.

Also there was a lot of work (mostly by Ying Huang) on the
mce-test testsuite which is covering more and more code, 
but of course could always need more work too.

> problem?  Or are we waiting for 32bit unification to complete?

The 32bit unification is complete, but the x86 maintainers
haven't merged it yet. 

> If so, I'd like to try to narrow down the problems or review
> patches (although I'm afraid I'm not so skillful).

Sure any review or additional testing is welcome.

I wanted to do full reposts this week anyways, so you
can start from there again.

> BTW, I looked over this patch set, and I couldn't
> find any problems except for one minor point.  I'll post
> a comment about it later.  It is very late, but better than nothing.

Great. Thanks. Can I add your Reviewed-by tags then?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

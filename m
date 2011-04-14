Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DE52900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 13:39:18 -0400 (EDT)
Date: Thu, 14 Apr 2011 19:37:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110414173741.GG15707@random.random>
References: <20110322150314.GC5698@random.random>
 <4D8907C2.7010304@fiec.espol.edu.ec>
 <20110322214020.GD5698@random.random>
 <20110323003718.GH5698@random.random>
 <4D8A2517.3090403@fiec.espol.edu.ec>
 <4D99E5C8.7090505@fiec.espol.edu.ec>
 <20110408190912.GI29444@random.random>
 <4D9F6AB6.6000809@fiec.espol.edu.ec>
 <4DA47D83.30707@fiec.espol.edu.ec>
 <4DA72E1C.7090900@fiec.espol.edu.ec>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4DA72E1C.7090900@fiec.espol.edu.ec>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Hello Alex,

On Thu, Apr 14, 2011 at 12:25:48PM -0500, Alex Villaci-s Lasso wrote:
> I retract that. I have tested 2.6.39-rc3 after a day of having
> several heavy applications loaded in memory, and the stalls do get
> worse when reversing the patch.

Well I was already afraid your stalling wasn't 100%
reproducible. Depends on background load like you said. I think if it
never happens when you didn't start the heavy applications yet is good
enough result for now. When we throttle on I/O and there are heavy
apps things may stall even without usb drive because the more memory
pressure the more every little write() or memory allocation, may stall
too regardless of compaction, we've no perfection in that area yet
(the best way to tackle this are the per-process write throttling
levels).

Bottom line is that the additional congestion created by the heavy app
is by far not easy to quantify or to assume as a reproducible, so it
is very possible it was the same as before and in general if we want
to apply that change it's cleaner to do it unconditionally for all
allocation orders and not in function of __GFP_NO_KSWAPD. So I think
the patch is still good to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

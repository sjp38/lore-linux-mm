Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05E236B008C
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 15:36:25 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oA1JaMTe015095
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 12:36:22 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz37.hot.corp.google.com with ESMTP id oA1JaLNc011098
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 12:36:21 -0700
Received: by pwj9 with SMTP id 9so1589019pwj.7
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 12:36:20 -0700 (PDT)
Date: Mon, 1 Nov 2010 12:36:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101101030353.607A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com>
References: <20101026220237.B7DA.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010261234230.5578@chino.kir.corp.google.com> <20101101030353.607A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010, KOSAKI Motohiro wrote:

> > The new tunable added in 2.6.36, /proc/pid/oom_score_adj, is necessary for 
> > the units that the badness score now uses.  We need a tunable with a much 
> 
> Who we?
> 

Linux users who care about prioritizing tasks for oom kill with a tunable 
that (1) has a unit, (2) has a higher resolution, and (3) is linear and 
not exponential.  Memcg doesn't solve this issue without incurring a 1% 
memory cost.

> > higher resolution than the oom_adj scale from -16 to +15, and one that 
> > scales linearly as opposed to exponentially.  Since that tunable is much 
> > more powerful than the oom_adj implementation, which never made any real 
> 
> The reason that you ware NAKed was not to introduce new powerful feature.
> It was caused to break old and used feature from applications.
> 

No, it doesn't, and you completely and utterly failed to show a single 
usecase that broke as a result of this because nobody can currently use 
oom_adj for anything other than polarization.  Thus, there's no backwards 
compatibility issue.

> > sense for defining oom killing priority for any purpose other than 
> > polarization, the old tunable is deprecated for two years.
> 
> You haven't tested your patch at all. Distro's initram script are using
> oom_adj interface and latest kernel show pointless warnings 
> "/proc/xx/oom_adj is deprecated, please use /proc/xx/oom_score_adj instead."
> at _every_ boot time.
> 

Yes, I've tested it, and it deprecates the tunable as expected.  A single 
warning message serves the purpose well: let users know one time without 
being overly verbose that the tunable is deprecated and give them 
sufficient time (2 years) to start using the new tunable.  That's how 
deprecation is done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

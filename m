Received: by qb-out-0506.google.com with SMTP id e21so6871505qba.0
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 10:11:23 -0800 (PST)
Message-ID: <2f11576a0802091011r61da1d67q3b7b114f495d780a@mail.gmail.com>
Date: Sun, 10 Feb 2008 03:11:22 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24-mm1] Mempolicy: silently restrict nodemask to allowed nodes V3
In-Reply-To: <1202499913.5346.60.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1202149243.5028.61.camel@localhost>
	 <20080205163406.270B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1202499913.5346.60.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, torvalds@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Lee-san

looks good for me.
I'll test about the head of week and report it by another mail.

Thanks!

> Was "Re: [2.6.24 regression][BUGFIX] numactl --interleave=all doesn't
> works on memoryless node."
>
> [Aside:  I noticed there were two slightly different distributions for
> this topic.  I've unified the distribution lists w/o dropping anyone, I
> think.  Apologies if you'd rather have been dropped...]
>
> Here's V3 of the patch, accomodating Kosaki Motohiro's suggestion for
> folding contextualize_policy() into mpol_check_policy() [because my
> "was_empty" argument "was ugly" ;-)].  It does seem to clean up the
> code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

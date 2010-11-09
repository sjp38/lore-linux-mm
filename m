Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECB76B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:48:31 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oA9NmNjA012340
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:48:23 -0800
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe17.cbf.corp.google.com with ESMTP id oA9NlMQI008384
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:48:22 -0800
Received: by pzk4 with SMTP id 4so8846pzk.31
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 15:48:21 -0800 (PST)
Date: Tue, 9 Nov 2010 15:48:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101109233541.13be4cd5@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1011091547030.30112@chino.kir.corp.google.com>
References: <20101101030353.607A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com> <20101109105801.BC30.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011091523370.26837@chino.kir.corp.google.com>
 <20101109233541.13be4cd5@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, Alan Cox wrote:

> > It's deprecated for a few years so users can gradually convert to the new 
> > tunable, it wasn't removed when the new one was introduced.  A higher 
> > resolution tunable that scales linearly with a unit is an advantage for 
> > Linux (for the minority of users who care about oom killing priority 
> > beyond the heuristic) and I think a few years is enough time for users to 
> > do a simple conversion to the new tunable.
> 
> Documentation/ABI/obsolete/
> 
> should have all obsoletes in it.
> 

Good point, the only documentation right now is in 
Documentation/feature-removal-schedule.txt and in the kernel log the first 
time oom_adj is written.  I'll generate a patch, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

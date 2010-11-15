Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1A88D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 05:38:14 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oAFAcBYI013453
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:38:11 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz5.hot.corp.google.com with ESMTP id oAFAbtbt009486
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:38:10 -0800
Received: by pzk37 with SMTP id 37so988862pzk.12
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:38:10 -0800 (PST)
Date: Mon, 15 Nov 2010 02:38:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: document obsolete oom_adj tunable
In-Reply-To: <20101115091908.BEEB.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011150234530.2986@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011091547030.30112@chino.kir.corp.google.com> <alpine.DEB.2.00.1011091555210.30112@chino.kir.corp.google.com> <20101115091908.BEEB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, KOSAKI Motohiro wrote:

> > /proc/pid/oom_adj was deprecated in August 2010 with the introduction of
> > the new oom killer heuristic.
> > 
> > This patch copies the Documentation/feature-removal-schedule.txt entry
> > for this tunable to the Documentation/ABI/obsolete directory so nobody
> > misses it.
> > 
> > Reported-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> NAK. You seems to think shouting claim makes some effect. but It's incorrect.
> Your childish shout doesn't solve any real world issue. Only code fix does.
> 

The tunable is deprecated.  If you are really that concerned about the 
existing users who you don't think can convert in the next two years, why 
don't you help them convert?  That fixes the issue, but you're not 
interested in that.  I offered to convert any open-source users you can 
list (the hardest part of the conversion is finding who to send patches to 
:).  You're only interested in continuing to assert your position as 
correct even when the kernel is obviously moving in a different direction.

Others may have a different opinion of who is being childish in this whole 
ordeal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFCC6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:37:08 -0500 (EST)
Date: Tue, 9 Nov 2010 23:35:41 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
Message-ID: <20101109233541.13be4cd5@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.DEB.2.00.1011091523370.26837@chino.kir.corp.google.com>
References: <20101101030353.607A.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com>
	<20101109105801.BC30.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1011091523370.26837@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> It's deprecated for a few years so users can gradually convert to the new 
> tunable, it wasn't removed when the new one was introduced.  A higher 
> resolution tunable that scales linearly with a unit is an advantage for 
> Linux (for the minority of users who care about oom killing priority 
> beyond the heuristic) and I think a few years is enough time for users to 
> do a simple conversion to the new tunable.

Documentation/ABI/obsolete/

should have all obsoletes in it.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

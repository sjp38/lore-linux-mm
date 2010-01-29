Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 51B056B0085
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 11:29:22 -0500 (EST)
Date: Fri, 29 Jan 2010 16:30:30 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
In-Reply-To: <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com>
	<20100129162137.79b2a6d4@lxorguk.ukuu.org.uk>
	<c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > Ultimately it is policy. The kernel simply can't read minds.
> >
> If so, all heuristics other than vm_size should be purged, I think.
> ...Or victim should be just determined by the class of application
> user sets. oom_adj other than OOM_DISABLE, searching victim process
> by black magic are all garbage.

oom_adj by value makes sense as do some of the basic heuristics - but a
lot of the complexity I would agree is completely nonsensical.

There are folks who use oom_adj weightings to influence things (notably
embedded and desktop). The embedded world would actually benefit on the
whole if the oom_adj was an absolute value because they usually know
precisely what they want to die and in what order.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

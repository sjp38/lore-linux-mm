Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 588806B002C
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:37:21 -0500 (EST)
Received: by dadv6 with SMTP id v6so9034757dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:37:20 -0800 (PST)
Date: Tue, 21 Feb 2012 14:36:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/10] mm/memcg: introduce page_relock_lruvec
In-Reply-To: <20120221173859.f57d00f5.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1202211426010.2012@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201532170.23274@eggly.anvils> <20120221173859.f57d00f5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 21 Feb 2012, KAMEZAWA Hiroyuki wrote:
> 
> No perforamce impact by replacing spin_lock_irq()/spin_unlock_irq() to
> spin_lock_irqsave() and spin_unlock_irqrestore() ?

None that I noticed - but that is not at all a reassuring answer!

It worries me a little.  I think it would make more or less difference
on different architectures, and I forget where x86 stands there - one
of the more or the less affected?  Worth branches down inside
page_relock_lruvec()?

It's also unfortunate to be "losing" the information of where _irq
is needed and where _irqsave (but not much gets lost with git).

It's something that can be fixed - and I think Konstantin's version
already keeps the variants: I just didn't want to get confused by them,
while focussing on the locking details.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

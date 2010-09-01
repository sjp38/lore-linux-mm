Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 601676B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 18:18:41 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o81MIdVM024454
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 15:18:40 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by kpbe19.cbf.corp.google.com with ESMTP id o81MIc1u005889
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 15:18:38 -0700
Received: by pwi4 with SMTP id 4so28274pwi.23
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 15:18:38 -0700 (PDT)
Date: Wed, 1 Sep 2010 15:18:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage
 normalization from oom_badness()
In-Reply-To: <20100831181911.87E7.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011508440.29305@chino.kir.corp.google.com>
References: <20100831181911.87E7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010, KOSAKI Motohiro wrote:

> ok, this one got no objection except original patch author.

Would you care to respond to my objections?

I replied to these two patches earlier with my nack, here they are:

	http://marc.info/?l=linux-mm&m=128273555323993
	http://marc.info/?l=linux-mm&m=128337879310476

Please carry on a useful debate of the issues rather than continually 
resending patches and labeling them as bugfixes, which they aren't.

> then, I'll push it to mainline. I'm glad that I who stabilization
> developer have finished this work.
> 

You're not the maintainer of this code, patches go through Andrew.

That said, I'm really tired of you trying to make this personal with me; 
I've been very respectful and accomodating during this discussion and I 
hope that you will be the same.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

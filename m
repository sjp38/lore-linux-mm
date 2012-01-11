Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 0D1E06B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:57:46 -0500 (EST)
Received: by ghrr18 with SMTP id r18so636061ghr.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 11:57:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F0D8FCE.7080202@redhat.com>
References: <20120109213156.0ff47ee5@annuminas.surriel.com>
 <20120109213357.148e7927@annuminas.surriel.com> <CAHGf_=rj=aDVGWXqdq7fh_LrCFnug_mPNuuE=YdXaWpvwyjfzg@mail.gmail.com>
 <4F0D8FCE.7080202@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Jan 2012 14:57:25 -0500
Message-ID: <CAHGf_=qJv99TbF2eNosbeHU5pzk2e3mDer0u2U+EsXdf2p5_Aw@mail.gmail.com>
Subject: Re: [PATCH -mm 2/2] mm: kswapd carefully invoke compaction
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com

> I believe we do need some background compaction, especially
> to help allocations from network interrupts.

I completely agree.


> If you believe the compaction is better done from some
> other thread, I guess we could do that, but truthfully, if
> kswapd spends a lot of time doing compaction, I made a
> mistake somewhere :)

I don't have much experience of compaction on real production systems.
but I have a few bad experience of background lumpy reclaim. If much
network allocation is happen when kswapd get stucked large order lumpy
reclaim, kswapd can't work for making order-0 job.it was bad. I'm only
worry about similar issue will occur.

But, ok, we can fix it when we actually observed such thing. So,
please go ahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

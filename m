Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E186A6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 21:41:49 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2772737iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:41:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100827012147.GC7353@localhost>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
	<20100826172038.GA6873@barrios-desktop>
	<20100827012147.GC7353@localhost>
Date: Fri, 27 Aug 2010 10:41:48 +0900
Message-ID: <AANLkTimLhZcP=eqB9TFfO_rgb-dhXUJh8iNTXuceuCq0@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on congestion_wait
 when there is no congestion
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Hi, Wu.

On Fri, Aug 27, 2010 at 10:21 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Minchan,
>
> It's much cleaner to keep the unchanged congestion_wait() and add a
> congestion_wait_check() for converting problematic wait sites. The
> too_many_isolated() wait is merely a protective mechanism, I won't
> bother to improve it at the cost of more code.

You means following as?

        while (unlikely(too_many_isolated(zone, file, sc))) {
                congestion_wait_check(BLK_RW_ASYNC, HZ/10);

                /* We are about to die and free our memory. Return now. */
                if (fatal_signal_pending(current))
                        return SWAP_CLUSTER_MAX;
        }


>
> Thanks,
> Fengguang
>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

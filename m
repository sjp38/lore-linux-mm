Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A3B536B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 08:01:36 -0500 (EST)
Received: by vws10 with SMTP id 10so939573vws.14
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 05:01:27 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
In-Reply-To: <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com> <20101208170504.1750.A69D9226@jp.fujitsu.com> <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
Date: Wed, 08 Dec 2010 08:01:24 -0500
Message-ID: <87oc8wa063.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> Make sense to me. If Ben is busy, I will measure it and send the result.

I've done measurements on the patched kernel. All that remains is to do
measurements on the baseline unpached case. To summarize the results
thusfar,

Times:
=======
                       user    sys     %cpu    inputs           outputs
Patched, drop          142     64      46      13557744         14052744
Patched, nodrop        55      57      33      13557936         13556680

vmstat:
========
                        free_pages      inact_anon      act_anon        inact_file      act_file        dirtied      written  reclaim
Patched, drop, pre      306043          37541           185463          276266          153955          3689674      3604959  1550641
Patched, drop, post     13233           38462           175252          536346          178792          5527564      5371563  3169155

Patched, nodrop, pre    475211          38602           175242          81979           178820          5527592      5371554  3169155
Patched, nodrop, post   7697            38959           176986          547984          180855          7324836      7132158  3169155

Altogether, it seems that something is horribly wrong, most likely with
my test (or rsync patch). I'll do the baseline benchmarks today.

Thoughts?

Thanks,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

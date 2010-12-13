Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C00F16B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 15:06:49 -0500 (EST)
Received: by qyk7 with SMTP id 7so3659239qyk.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:06:46 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
In-Reply-To: <20101213153105.GA2344@barrios-desktop>
References: <cover.1291568905.git.minchan.kim@gmail.com> <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com> <20101208170504.1750.A69D9226@jp.fujitsu.com> <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com> <87oc8wa063.fsf@gmail.com> <AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com> <20101213153105.GA2344@barrios-desktop>
Date: Mon, 13 Dec 2010 15:06:38 -0500
Message-ID: <87lj3t30a9.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 00:31:05 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
> In summary, my patch enhances a littie bit about elapsed time in
> memory pressure environment and enhance reclaim effectivness(reclaim/reclaim)
> with x2. It means reclaim latency is short and doesn't evict working set
> pages due to invalidated pages.
> 
Thank you very much for this testing! I'm very sorry I've been unable to
contribute more recently. My last exam is on Wednesday and besides some
grading that is the end of the semester.  Is there anything you would
like me to do? Perhaps reproducing these results on my setup would be
useful?

> Look at reclaim effectivness. Patched rsync enhances x2 about reclaim
> effectiveness and compared to mmotm-12-03, mmotm-12-03-fadvise enhances
> 3 minute about elapsed time in stress environment. 
> I think it's due to reduce scanning, reclaim overhead.
> 
Good good. This looks quite promising.

> In no-stress enviroment, fadivse makes program little bit slow.
> I think because there are many pgfault. I don't know why it happens.
> Could you guess why it happens?
> 
Hmm, nothing comes to mind. As I've said in the past, rsync should
require each page only once. Perhaps perf might offer some insight into
where this time is being spent?

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

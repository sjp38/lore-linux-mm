Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 846296B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 20:02:30 -0400 (EDT)
Received: by qyk7 with SMTP id 7so3195370qyk.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 17:02:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110808110659.31053.92935.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
	<20110808110659.31053.92935.stgit@localhost6>
Date: Tue, 9 Aug 2011 09:02:28 +0900
Message-ID: <CAEwNFnBojMWL1QRfn_buhwUwMOBRGSUGdWBgmzdt9vsCVmLFmQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] vmscan: activate executable pages after first usage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Aug 8, 2011 at 8:07 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> Logic added in commit v2.6.30-5507-g8cab475
> (vmscan: make mapped executable pages the first class citizen)
> was noticeably weakened in commit v2.6.33-5448-g6457474
> (vmscan: detect mapped file pages used only once)
>
> Currently these pages can become "first class citizens" only after second usage.
>
> After this patch page_check_references() will activate they after first usage,
> and executable code gets yet better chance to stay in memory.
>
> TODO:
> run some cool tests like in v2.6.30-5507-g8cab475 =)
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---

It might be a very controversial topic.
AFAIR, at least, we did when vmscan: make mapped executable pages the
first class citizen was merged. :)

You try to change behavior.

Old : protect *working set* executable page
New: protect executable page *unconditionally*.

At least, old logic can ignore some executable pages which are not
accessed recently.

Wu had many testing to persuade others.
As you said, we need some number to change policy.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

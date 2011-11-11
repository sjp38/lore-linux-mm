Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E66B6B0072
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 18:36:05 -0500 (EST)
Received: by yenm10 with SMTP id m10so1186254yen.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:36:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111124005.7371.63176.stgit@zurg>
References: <20110729075837.12274.58405.stgit@localhost6>
	<20111111124005.7371.63176.stgit@zurg>
Date: Sat, 12 Nov 2011 08:36:03 +0900
Message-ID: <CAEwNFnBKiM=0YVYzs=_fbHCac96J_yb+SbnCMpYGFJLLMSCsxg@mail.gmail.com>
Subject: Re: [PATCH v3 3/4] mm-tracepoint: rename page-free events
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

On Fri, Nov 11, 2011 at 10:40 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> Rename mm_page_free_direct into mm_page_free
> and mm_pagevec_free into mm_page_free_batched
>
> Since v2.6.33-5426-gc475dab kernel trigger mm_page_free_direct for all freed pages,
> not only for directly freed. So, let's name it properly.
> For pages freed via page-list we also trigger mm_page_free_batched event.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

1+ for clear naming but I am not quite sure event name change is
always OK for compatibility of old perf.
At least, we will need to Cced Ingo, I think.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9AADD6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 18:56:14 -0400 (EDT)
Received: by qyk32 with SMTP id 32so1373563qyk.14
        for <linux-mm@kvack.org>; Mon, 25 Jul 2011 15:56:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311625159-13771-2-git-send-email-jweiner@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
	<1311625159-13771-2-git-send-email-jweiner@redhat.com>
Date: Tue, 26 Jul 2011 07:56:12 +0900
Message-ID: <CAEwNFnBB_WPv5mh65+Uis8OQdiq0p_j8UtuQsezDxRw4Ye3w8Q@mail.gmail.com>
Subject: Re: [patch 1/5] mm: page_alloc: increase __GFP_BITS_SHIFT to include __GFP_OTHER_NODE
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Jul 26, 2011 at 5:19 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> From: Johannes Weiner <hannes@cmpxchg.org>
>
> __GFP_OTHER_NODE is used for NUMA allocations on behalf of other
> nodes. =C2=A0It's supposed to be passed through from the page allocator t=
o
> zone_statistics(), but it never gets there as gfp_allowed_mask is not
> wide enough and masks out the flag early in the allocation path.
>
> The result is an accounting glitch where successful NUMA allocations
> by-agent are not properly attributed as local.
>
> Increase __GFP_BITS_SHIFT so that it includes __GFP_OTHER_NODE.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

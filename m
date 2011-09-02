Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4546B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 23:29:48 -0400 (EDT)
Received: by iagv1 with SMTP id v1so3513111iag.14
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 20:29:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110901130542.GG14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
	<e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
	<20110901130542.GG14369@suse.de>
Date: Fri, 2 Sep 2011 12:29:45 +0900
Message-ID: <CAEwNFnAq99Bj0kZq6aa2mOc9RoTT=T69s4BaA7i_5yieaFLPEA@mail.gmail.com>
Subject: Re: [PATCH 1/3] Correct isolate_mode_t bitwise type
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Sep 1, 2011 at 10:05 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Sun, Nov 13, 2011 at 01:37:41AM +0900, Minchan Kim wrote:
>> [c1e8b0ae8, mm-change-isolate-mode-from-define-to-bitwise-type]
>> made a mistake on the bitwise type.
>>
>
> Minor nit, commit c1e8b0ae8 does not exist anywhere. I suspect you
> are looking at a git tree generated from the mmotm quilt series. It
> would be easier if you had said "This patch should be merged with
> mm-change-isolate-mode-from-define-to-bitwise-type.patch in mmotm".

Right you are. I did it by habit without realizing just quilt series. :(
For preventing such bad thing, I always use [git commit id, patch
name] together these day. Fortunately, it seems to be effective. But
unfortunately, I couldn't prevent your wasted time which spend until
notice that.

I will be careful in the future.

>
> Otherwise, looks ok.

Thanks, Mel.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBD336B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 11:31:49 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w204so154911381qka.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 08:31:49 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id j64si4456479ita.81.2016.09.09.08.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 08:31:30 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id i184so19759924itf.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 08:31:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 Sep 2016 08:31:27 -0700
Message-ID: <CA+55aFxcP_ydi9KCXmMQe5tv5GXw2QmTvnCQBM7ZjEuRgKiR4g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/4] Reduce tree_lock contention during swap and
 reclaim of a single file v1
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 9, 2016 at 2:59 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> The progression of this series has been unsatisfactory.

Yeah, I have to say that I particularly don't like patch #1. It's some
rather nasty complexity for dubious gains, and holding the lock for
longer times might have downsides.

And the numbers seem to not necessarily be in favor of patch #3
either, which I would have otherwise been predisposed to like (ie it
looks fairly targeted and not very complex).

#2 seems trivially correct but largely irrelevant.

So I think this series is one of those "we need to find that it makes
a big positive impact" to make sense.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

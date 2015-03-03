Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC326B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 01:56:15 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so54642430iec.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 22:56:15 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id sb11si699006igb.26.2015.03.02.22.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 22:56:14 -0800 (PST)
Received: by igdh15 with SMTP id h15so24134168igd.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 22:56:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150303052004.GM18360@dastard>
References: <20150302010413.GP4251@dastard>
	<CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
	<20150303014733.GL18360@dastard>
	<CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
	<CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
	<20150303052004.GM18360@dastard>
Date: Mon, 2 Mar 2015 22:56:14 -0800
Message-ID: <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 2, 2015 at 9:20 PM, Dave Chinner <david@fromorbit.com> wrote:
>>
>> But are those migrate-page calls really common enough to make these
>> things happen often enough on the same pages for this all to matter?
>
> It's looking like that's a possibility.

Hmm. Looking closer, commit 10c1045f28e8 already should have
re-introduced the "pte was already NUMA" case.

So that's not it either, afaik. Plus your numbers seem to say that
it's really "migrate_pages()" that is done more. So it feels like the
numa balancing isn't working right.

But I'm not seeing what would cause that in that commit. It really all
looks the same to me. The few special-cases it drops get re-introduced
later (although in a different form).

Mel, do you see what I'm missing?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

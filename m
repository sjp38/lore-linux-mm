Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4B26B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:18:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so4414085pfi.23
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:18:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e1si3007494pld.493.2017.12.14.03.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:18:24 -0800 (PST)
Date: Thu, 14 Dec 2017 12:18:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20171214111817.xnyxgtremfspjk7f@hirez.programming.kicks-ass.net>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <CANrsvRMAci5Vxj0kKsgW4-cgK4X4BAvq9jOwkAx0TWHqBjogVw@mail.gmail.com>
 <20171214030711.gtxzm57h7h4hwbfe@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214030711.gtxzm57h7h4hwbfe@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

On Wed, Dec 13, 2017 at 10:07:11PM -0500, Theodore Ts'o wrote:
> interpreted this as the lockdep maintainers saying, "hey, not my
> fault, it's the subsystem maintainer's fault for not properly
> classifying the locks" --- and thus dumping the responsibility in the
> subsystem maintainers' laps.

Let me clarify that I (as lockdep maintainer) disagree with that
sentiment. I have spend a lot of time over the years staring at random
code trying to fix lockdep splats. Its awesome if corresponding
subsystem maintainers help out and many have, but I very much do not
agree its their problem and their problem alone.

This attitude is one of the biggest issues I have with the crossrelease
stuff and why I don't disagree with Ingo taking it out (for now).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

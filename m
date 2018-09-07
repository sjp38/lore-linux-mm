Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE02D6B7D28
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:37:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e14-v6so13044775qtp.17
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:37:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j14-v6sor2807768qvo.105.2018.09.07.00.36.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:36:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180905214303.GA30178@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org> <20180905214303.GA30178@cmpxchg.org>
From: Daniel Drake <drake@endlessm.com>
Date: Fri, 7 Sep 2018 15:36:56 +0800
Message-ID: <CAD8Lp44vHpMiWZdU9+mp-pe2kXmnxF1zm20SNWf2BVunk8c46g@mail.gmail.com>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Thu, Sep 6, 2018 at 5:43 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Peter, do the changes from v3 look sane to you?
>
> If there aren't any further objections, I was hoping we could get this
> lined up for 4.20.

That would be excellent. I just retested the latest version at
http://git.cmpxchg.org/cgit.cgi/linux-psi.git (Linux 4.18) and the
results are great.

Test setup:
Endless OS
GeminiLake N4200 low end laptop
2GB RAM
swap (and zram swap) disabled

Baseline test: open a handful of large-ish apps and several website
tabs in Google Chrome.
Results: after a couple of minutes, system is excessively thrashing,
mouse cursor can barely be moved, UI is not responding to mouse
clicks, so it's impractical to recover from this situation as an
ordinary user

Add my simple killer:
https://gist.github.com/dsd/a8988bf0b81a6163475988120fe8d9cd
Results: when the thrashing causes the UI to become sluggish, the
killer steps in and kills something (usually a chrome tab), and the
system remains usable. I repeatedly opened more apps and more websites
over a 15 minute period but I wasn't able to get the system to a point
of UI unresponsiveness.

Thanks,
Daniel

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 952E26B027B
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:37:42 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i4-v6so5220853ite.3
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:37:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j129-v6sor8476236jac.103.2018.07.12.10.37.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 10:37:41 -0700 (PDT)
MIME-Version: 1.0
References: <20180712172942.10094-1-hannes@cmpxchg.org>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jul 2018 10:37:30 -0700
Message-ID: <CAADWXX_ADRyY+HDyw_2Ofa4b9g1fpCNe8xO3xMf20jfWsyCnQg@mail.gmail.com>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mingo@redhat.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, shakeelb@google.com, linux-mm@kvack.org, cgroups@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Thu, Jul 12, 2018 at 10:27 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> PSI aggregates and reports the overall wallclock time in which the
> tasks in a system (or cgroup) wait for contended hardware resources.

No comments on the patches themselves (the concept looks sane, and I'm
finding it more intriguing for non-oom uses than for oom), but just a
note to say that gmail hates you and marked every single patch as spam
for some reason.

I have no idea why. All the headers look fine, DKIM passes, nothing
bad stands out.

So it must be personal.

             Linus

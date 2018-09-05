Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5A956B7530
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:43:10 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d23-v6so6044044ywb.2
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:43:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64-v6sor591018ybf.78.2018.09.05.14.43.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 14:43:05 -0700 (PDT)
Date: Wed, 5 Sep 2018 17:43:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Message-ID: <20180905214303.GA30178@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828172258.3185-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 28, 2018 at 01:22:49PM -0400, Johannes Weiner wrote:
> This version 4 of the PSI series incorporates feedback from Peter and
> fixes two races in the lockless aggregator that Suren found in his
> testing and which caused the sample calculation to sometimes underflow
> and record bogusly large samples; details at the bottom of this email.

Peter, do the changes from v3 look sane to you?

If there aren't any further objections, I was hoping we could get this
lined up for 4.20.

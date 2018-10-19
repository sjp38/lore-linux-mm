Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFBC6B0010
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:07:13 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 127-v6so2559777pgb.7
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:07:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s5-v6si22827928pgm.448.2018.10.18.19.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 19:07:12 -0700 (PDT)
Date: Thu, 18 Oct 2018 19:07:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory,
 and IO v4
Message-Id: <20181018190710.fcea1c5f9c3b0c15d37ee762@linux-foundation.org>
In-Reply-To: <20180828172258.3185-1-hannes@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 28 Aug 2018 13:22:49 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> This version 4 of the PSI series incorporates feedback from Peter and
> fixes two races in the lockless aggregator that Suren found in his
> testing and which caused the sample calculation to sometimes underflow
> and record bogusly large samples; details at the bottom of this email.

We've had very little in the way of review activity for the PSI
patchset.  According to the changelog tags, anyway.

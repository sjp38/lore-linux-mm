Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56E376B026F
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:44:25 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e93-v6so16123069plb.5
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:44:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 25-v6si20380556pfp.108.2018.07.12.16.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:44:24 -0700 (PDT)
Date: Thu, 12 Jul 2018 16:44:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-Id: <20180712164422.a53cc0f9c26b078dbc7e5731@linux-foundation.org>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 12 Jul 2018 13:29:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

>
> ...
>
> The io file is similar to memory. Because the block layer doesn't have
> a concept of hardware contention right now (how much longer is my IO
> request taking due to other tasks?), it reports CPU potential lost on
> all IO delays, not just the potential lost due to competition.

Probably dumb question: disks aren't the only form of IO.  Does it make
sense to accumulate PSI for other forms of IO?  Networking comes to
mind...

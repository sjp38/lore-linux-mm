Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9516B0271
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:05:24 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id b141-v6so7522705ywh.12
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:05:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13-v6sor3069034ybr.73.2018.07.30.11.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 11:05:23 -0700 (PDT)
Date: Mon, 30 Jul 2018 11:05:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180730180520.GL1206094@devbig004.ftw2.facebook.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd>
 <20180730154035.GC4567@cmpxchg.org>
 <20180730173940.GB881@amd>
 <20180730175120.GJ1206094@devbig004.ftw2.facebook.com>
 <dfc3c810-8918-add4-b818-8b9c294f5ea4@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfc3c810-8918-add4-b818-8b9c294f5ea4@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Pavel Machek <pavel@ucw.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hello,

On Mon, Jul 30, 2018 at 10:54:05AM -0700, Randy Dunlap wrote:
> I'd say he's trying to make something that is readable and easier to
> understand for users.

Sure, it's perfectly fine to make those suggestions and discuss but
the counter points have already been discussed (e.g. PSI is a known
acronym associated with pressure and internal symbols all use them for
brevity and uniqueness).  There's no clear technically winning choice
here and it's a decision of a relatively low importance given that
it's confined to kernel config.  I can't see any merit in turning it
into a last-word match.

Thanks.

-- 
tejun

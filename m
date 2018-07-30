Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD0F6B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:37:44 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i23-v6so10741110qtf.9
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:37:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u21-v6sor5503640qte.45.2018.07.30.08.37.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 08:37:41 -0700 (PDT)
Date: Mon, 30 Jul 2018 11:40:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180730154035.GC4567@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727220123.GB18879@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Jul 28, 2018 at 12:01:23AM +0200, Pavel Machek wrote:
> > 		How do you use this feature?
> > 
> > A kernel with CONFIG_PSI=y will create a /proc/pressure directory with
> > 3 files: cpu, memory, and io. If using cgroup2, cgroups will also
> 
> Could we get the config named CONFIG_PRESSURE to match /proc/pressure?
> "PSI" is little too terse...

I'd rather have the internal config symbol match the naming scheme in
the code, where psi is a shorter, unique token as copmared to e.g.
pressure, press, prsr, etc.

The prompt text that the user primarily sees spells out "Pressure", so
I don't think this is confusing.

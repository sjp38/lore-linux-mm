Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3F16B000C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:50:12 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id k7-v6so2748352ljk.18
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:50:12 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id a20-v6si512529lfd.173.2018.08.07.04.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:50:10 -0700 (PDT)
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v3
References: <20180801151958.32590-1-hannes@cmpxchg.org>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <5576a988-fca9-15a5-5fa8-16f704ea20fb@sony.com>
Date: Tue, 7 Aug 2018 13:50:09 +0200
MIME-Version: 1.0
In-Reply-To: <20180801151958.32590-1-hannes@cmpxchg.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 08/01/2018 05:19 PM, Johannes Weiner wrote:
>
> A kernel with CONFIG_PSI=y will create a /proc/pressure directory with
> 3 files: cpu, memory, and io. If using cgroup2, cgroups will also have
> cpu.pressure, memory.pressure and io.pressure files, which simply
> aggregate task stalls at the cgroup level instead of system-wide.
>
Usually there are objections to add more stuff to /proc. Is this an exception?

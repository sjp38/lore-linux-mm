Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 976536B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:39:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y124-v6so15599005qkc.8
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:39:34 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id t9-v6si5710869qti.326.2018.05.14.08.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 May 2018 08:39:33 -0700 (PDT)
Date: Mon, 14 May 2018 15:39:33 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] psi: pressure stall information for CPU, memory,
 and IO
In-Reply-To: <20180507210135.1823-1-hannes@cmpxchg.org>
Message-ID: <010001635f4e8be9-94e7be7a-e75c-438c-bffb-5b56301c4c55-000000@email.amazonses.com>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, 7 May 2018, Johannes Weiner wrote:

> What to make of this number? If CPU utilization is at 100% and CPU
> pressure is 0, it means the system is perfectly utilized, with one
> runnable thread per CPU and nobody waiting. At two or more runnable
> tasks per CPU, the system is 100% overcommitted and the pressure
> average will indicate as much. From a utilization perspective this is
> a great state of course: no CPU cycles are being wasted, even when 50%
> of the threads were to go idle (and most workloads do vary). From the
> perspective of the individual job it's not great, however, and they
> might do better with more resources. Depending on what your priority
> is, an elevated "some" number may or may not require action.

This looks awfully similar to loadavg. Problem is that loadavg gets
screwed up by tasks blocked waiting for I/O. Isnt there some way to fix
loadavg instead?

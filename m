Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4004E6B0006
	for <linux-mm@kvack.org>; Mon, 14 May 2018 16:15:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j33-v6so16421150qtc.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 13:15:52 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id h12-v6si7078478qte.291.2018.05.14.13.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 May 2018 13:15:50 -0700 (PDT)
Date: Mon, 14 May 2018 20:15:50 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] psi: pressure stall information for CPU, memory,
 and IO
In-Reply-To: <20180514185520.GA7398@cmpxchg.org>
Message-ID: <01000163604b7e9e-c2729157-aed2-4f5b-bebe-1bf16261ab88-000000@email.amazonses.com>
References: <20180507210135.1823-1-hannes@cmpxchg.org> <010001635f4e8be9-94e7be7a-e75c-438c-bffb-5b56301c4c55-000000@email.amazonses.com> <20180514185520.GA7398@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, 14 May 2018, Johannes Weiner wrote:

> Since I'm using the same model and infrastructure for memory and IO
> load as well, IMO it makes more sense to present them in a coherent
> interface instead of trying to retrofit and change the loadavg file,
> which might not even be possible.

Well I keep looking at the loadavg output from numerous tools and then in
my mind I divide by the number of processors, guess if any of the threads
would be doing I/O and if I cannot figure that out groan and run "vmstat"
for awhile to figure that out.

Lets have some numbers there that make more sense please.

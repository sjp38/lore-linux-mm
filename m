Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D12C38E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:58:15 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id c128so14993841itc.0
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:58:15 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r3si3695852ioa.63.2018.12.17.06.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 06:58:14 -0800 (PST)
Date: Mon, 17 Dec 2018 15:57:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/6] psi: eliminate lazy clock mode
Message-ID: <20181217145754.GB2218@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-4-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214171508.7791-4-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Fri, Dec 14, 2018 at 09:15:05AM -0800, Suren Baghdasaryan wrote:
> Eliminate the idle mode and keep the worker doing 2s update intervals
> at all times.

That sounds like a bad deal.. esp. so for battery powered devices like
say Andoird.

In general the push has been to always idle everything, see NOHZ and
NOHZ_FULL and all the work that's being put into getting rid of any and
all period work.

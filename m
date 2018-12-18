Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFC48E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 06:20:54 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id p12so5044449wrt.17
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:20:54 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 60si2010671wrb.246.2018.12.18.03.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 03:20:52 -0800 (PST)
Date: Tue, 18 Dec 2018 12:20:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Message-ID: <20181218112037.GB16284@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-7-surenb@google.com>
 <20181217162223.GD2218@hirez.programming.kicks-ass.net>
 <CAJuCfpHGsDnE-eAHY1QnX949stA3cvNA=078q1swqVnz95aJfg@mail.gmail.com>
 <20181218104622.GB15430@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218104622.GB15430@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Tue, Dec 18, 2018 at 11:46:22AM +0100, Peter Zijlstra wrote:
> On Mon, Dec 17, 2018 at 05:21:05PM -0800, Suren Baghdasaryan wrote:
> > On Mon, Dec 17, 2018 at 8:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > > How well has this thing been fuzzed? Custom string parser, yay!
> > 
> > Honestly, not much. Normal cases and some obvious corner cases. Will
> > check if I can use some fuzzer to get more coverage or will write a
> > script.
> > I'm not thrilled about writing a custom parser, so if there is a
> > better way to handle this please advise.
> 
> The grammar seems fairly simple, something like:
> 
>   some-full = "some" | "full" ;
>   threshold-abs = integer ;
>   threshold-pct = integer, { "%" } ;

Sorry, no {} there obviously. That '%' isn't optional.

>   threshold = threshold-abs | threshold-pct ;
>   window = integer ;
>   trigger = some-full, space, threshold, space, window ;

Clearly it's been a fair while since I wrote BNF like stuff ;-)

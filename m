Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B09368E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:13:25 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so6810661pfe.10
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:13:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id q5si978624pgb.245.2019.01.17.00.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 00:13:24 -0800 (PST)
Date: Thu, 17 Jan 2019 09:13:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Message-ID: <20190117081314.GD10486@hirez.programming.kicks-ass.net>
References: <20190110220718.261134-1-surenb@google.com>
 <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
 <20190116132446.GF10803@hirez.programming.kicks-ass.net>
 <CAJuCfpEJW6Uq4GSGEGLKOM4K7ySHUeTGrSUGM1+EJSQ16d8SJg@mail.gmail.com>
 <20190116191728.GA1380@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116191728.GA1380@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Wed, Jan 16, 2019 at 02:17:28PM -0500, Johannes Weiner wrote:

> > > Also, you probably want to use atomic_t for g->polling, because we
> > > (sadly) have architectures where regular stores and atomic ops don't
> > > work 'right'.
> > 
> > Oh, I see. Will do. Thanks!
> 
> Yikes, that's news to me too. Good to know.

See Documentation/atomic_t.txt, specifically the atomic_set() part in
SEMANTICS.

Archs that suffer this include (but are not limited to): parisc,
sparc32-smp, something arc.

And yes, I would dearly love to kill all SMP support for architectures
like that..

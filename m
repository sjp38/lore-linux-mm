Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0F6A6B0285
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:04:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f63-v6so940301wmi.4
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:04:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f11-v6si983211edn.256.2018.05.08.07.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 07:04:56 -0700 (PDT)
Date: Tue, 8 May 2018 10:06:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180508140648.GB2900@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <024fba07-eece-3878-0924-ea9fd601542d@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <024fba07-eece-3878-0924-ea9fd601542d@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:42:36PM -0700, Randy Dunlap wrote:
> On 05/07/2018 02:01 PM, Johannes Weiner wrote:
> > + * The ratio is tracked in decaying time averages over 10s, 1m, 5m
> > + * windows. Cumluative stall times are tracked and exported as well to
> 
>                Cumulative
> 

> > +/**
> > + * psi_memstall_leave - mark the end of an memory stall section
> 
>                                     end of a memory

Thanks Randy, I'll get those fixed.

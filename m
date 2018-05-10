Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B69B46B0614
	for <linux-mm@kvack.org>; Thu, 10 May 2018 10:11:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 3-v6so1512475wry.0
        for <linux-mm@kvack.org>; Thu, 10 May 2018 07:11:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q10-v6si1256824edk.369.2018.05.10.07.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 07:11:43 -0700 (PDT)
Date: Thu, 10 May 2018 10:13:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180510141334.GE19348@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509100551.GL12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509100551.GL12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 12:05:51PM +0200, Peter Zijlstra wrote:
> On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> > +	u64 some[NR_PSI_RESOURCES] = { 0, };
> > +	u64 full[NR_PSI_RESOURCES] = { 0, };
> 
> > +		some[r] /= max(nonidle_total, 1UL);
> > +		full[r] /= max(nonidle_total, 1UL);
> 
> That's a bare 64bit divide.. that typically failed to build on 32bit
> archs.

Ah yes, I'll switch that to do_div(). Thanks

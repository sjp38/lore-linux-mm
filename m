Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 590DE6B010C
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 12:51:05 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id ur14so9091848igb.4
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 09:51:05 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id pe7si22639859icc.6.2014.03.18.09.51.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Mar 2014 09:51:03 -0700 (PDT)
Date: Tue, 18 Mar 2014 17:50:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Lsf] [LSF/MM TOPIC] Testing Large-Memory Hardware
Message-ID: <20140318165059.GI22095@laptop.programming.kicks-ass.net>
References: <5328753B.2050107@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5328753B.2050107@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>

On Tue, Mar 18, 2014 at 09:32:59AM -0700, Dave Hansen wrote:
> I have a quick topic that could perhaps be addressed along with the
> testing topic that Dave Jones proposed.  I won't be attending, but there
> will be a couple of other Intel folks there.  This should be a fairly
> quick thing to address.
> 
> Topic:
> 
> Fengguang Wu who runs the wonderful LKP and 0day build tests was
> recently asking if I thought there was value in adding a large-memory
> system, say with 1TB of RAM.  LKP is the system that generates these
> kinds of automated bug reports and performance tests:
> 
> 	http://lkml.org/lkml/2014/3/9/201
> 
> My gut reaction was that we'd probably be better served by putting
> resources in to systems with higher core counts rather than lots of RAM.
>  I have encountered the occasional boot bug on my 1TB system, but it's
> far from a frequent occurrence, and even more infrequent to encounter
> things at runtime.
> 
> Would folks agree with that?  What kinds of tests, benchmarks, stress
> tests, etc... do folks run that are both valuable and can only be run on
> a system with a large amount of actual RAM?

We had a sched-numa + kvm fail on really large systems the other day,
but yeah in general such problems tend to be rare. Then again, without
test coverage they will always be rare, for even if there were problems,
nobody would notice :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1916B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:30:13 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so17142960pab.37
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:30:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id oq9si19284451pac.122.2014.02.18.11.30.09
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 11:30:09 -0800 (PST)
Subject: [RFC][PATCH 0/6] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Tue, 18 Feb 2014 11:30:08 -0800
Message-Id: <20140218193008.CA410E17@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, ak@linux.intel.com, alex.shi@linaro.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, tim.c.chen@linux.intel.com, x86@kernel.org, peterz@infradead.org, Dave Hansen <dave@sr71.net>

I originally went to look at this becuase I realized that newer
CPUs were not present in the intel_tlb_flushall_shift_set() code.

I went to try to figure out where to stick newer CPUs (do we
consider them more like SandyBridge or IvyBridge), and was not
able to repeat the original experiments.

Instead, this set does:
 1. Rework the code a bit to ready it for tracepoints
 2. Add tracepoints
 3. Add a new tunable and set it to a sane value

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

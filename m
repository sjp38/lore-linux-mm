Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EEF2D82F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:02:02 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so27227574wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:02:02 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id i7si6622748wje.113.2015.10.01.04.02.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:02:01 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:01:19 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 01/25] x86, fpu: add placeholder for Processor Trace
 XSAVE state
In-Reply-To: <20150928191818.34AAC17E@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011237580.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191818.34AAC17E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, 28 Sep 2015, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> There is an XSAVE state component for Intel Processor Trace.  But,
> we do not use it and do not expect to ever use it.
> 
> We add a placeholder in the code for it so it is not a mystery and
> also so we do not need an explicit enum initialization for Protection
> Keys in a moment.
> 
> Why will we never use it?  According to Andi Kleen:
> 
> 	The XSAVE support assumes that there is a single buffer
> 	for each thread. But perf generally doesn't work this
> 	way, it usually has only a single perf event per CPU per
> 	user, and when tracing multiple threads on that CPU it
> 	inherits perf event buffers between different threads. So
> 	XSAVE per thread cannot handle this inheritance case
> 	directly.
> 
> 	Using multiple XSAVE areas (another one per perf event)
> 	would defeat some of the state caching that the CPUs do.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5EA6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 20:55:09 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wp18so3480728obc.23
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 17:55:09 -0800 (PST)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id m4si4281823oel.113.2014.03.06.17.55.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 17:55:08 -0800 (PST)
Message-ID: <1394157304.2555.21.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 6/7] x86: mm: set TLB flush tunable to sane value
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 06 Mar 2014 17:55:04 -0800
In-Reply-To: <20140306004529.5510B23D@viggo.jf.intel.com>
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>
	 <20140306004529.5510B23D@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Now that we have some shiny new tracepoints, we can actually
> figure out what the heck is going on.
> 
> During a kernel compile, 60% of the flush_tlb_mm_range() calls
> are for a single page.  It breaks down like this:

It would be interesting to see similar data for opposite workloads with
more random access patterns. That's normally when things start getting
fun in the tlb world.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

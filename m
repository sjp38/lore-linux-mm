Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36B646B0069
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:19:57 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so49389wgh.10
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:19:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h13si14480354wjr.107.2014.04.22.14.19.55
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 14:19:55 -0700 (PDT)
Message-ID: <5356DCEF.3050506@redhat.com>
Date: Tue, 22 Apr 2014 17:19:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] x86: mm: trace tlb flushes
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182425.93E696A3@viggo.jf.intel.com>
In-Reply-To: <20140421182425.93E696A3@viggo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/21/2014 02:24 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> We don't have any good way to figure out what kinds of flushes
> are being attempted.  Right now, we can try to use the vm
> counters, but those only tell us what we actually did with the
> hardware (one-by-one vs full) and don't tell us what was actually
> _requested_.
> 
> This allows us to select out "interesting" TLB flushes that we
> might want to optimize (like the ranged ones) and ignore the ones
> that we have very little control over (the ones at context
> switch).
> 
> Also, since we have a pair of tracepoint calls in
> flush_tlb_mm_range(), we can time the deltas between them to make
> sure that we got the "invlpg vs. global flush" balance correct in
> practice.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

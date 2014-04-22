Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3890D6B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:34:08 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so135908eek.34
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:34:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o46si100102eem.9.2014.04.22.14.34.05
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 14:34:06 -0700 (PDT)
Message-ID: <5356E041.3060709@redhat.com>
Date: Tue, 22 Apr 2014 17:33:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] x86: mm: set TLB flush tunable to sane value (33)
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182428.FC2104C1@viggo.jf.intel.com>
In-Reply-To: <20140421182428.FC2104C1@viggo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/21/2014 02:24 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This has been run through Intel's LKP tests across a wide range
> of modern sytems and workloads and it wasn't shown to make a
> measurable performance difference positive or negative.
> 
> Now that we have some shiny new tracepoints, we can actually
> figure out what the heck is going on.
> 
> During a kernel compile, 60% of the flush_tlb_mm_range() calls
> are for a single page.  It breaks down like this:

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 974FB6B0044
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 12:54:13 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so4788001eek.18
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:54:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u5si60585979een.113.2014.04.22.09.54.10
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 09:54:11 -0700 (PDT)
Message-ID: <53569EA4.2000308@redhat.com>
Date: Tue, 22 Apr 2014 12:53:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] x86: mm: clean up tlb flushing code
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182420.307A0C57@viggo.jf.intel.com>
In-Reply-To: <20140421182420.307A0C57@viggo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/21/2014 02:24 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The
> 
> 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
> 
> line of code is not exactly the easiest to audit, especially when
> it ends up at two different indentation levels.  This eliminates
> one of the the copy-n-paste versions.  It also gives us a unified
> exit point for each path through this function.  We need this in
> a minute for our tracepoint.
> 
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

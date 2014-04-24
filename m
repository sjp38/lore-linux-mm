Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7FAD6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 04:49:28 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1552374eek.24
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 01:49:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si7286872eei.358.2014.04.24.01.49.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 01:49:27 -0700 (PDT)
Date: Thu, 24 Apr 2014 09:49:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] x86: mm: fix missed global TLB flush stat
Message-ID: <20140424084922.GR23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182422.DE5E728F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140421182422.DE5E728F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On Mon, Apr 21, 2014 at 11:24:22AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> If we take the
> 
> 	if (end == TLB_FLUSH_ALL || vmflag & VM_HUGETLB) {
> 		local_flush_tlb();
> 		goto out;
> 	}
> 
> path out of flush_tlb_mm_range(), we will have flushed the tlb,
> but not incremented NR_TLB_LOCAL_FLUSH_ALL.  This unifies the
> way out of the function so that we always take a single path when
> doing a full tlb flush.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

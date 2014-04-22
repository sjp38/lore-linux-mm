Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id B39926B0055
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:15:50 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so5106616wes.8
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 10:15:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b1si5682389wiz.37.2014.04.22.10.15.48
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 10:15:49 -0700 (PDT)
Message-ID: <5356A3B6.30006@redhat.com>
Date: Tue, 22 Apr 2014 13:15:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] x86: mm: fix missed global TLB flush stat
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182422.DE5E728F@viggo.jf.intel.com>
In-Reply-To: <20140421182422.DE5E728F@viggo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/21/2014 02:24 PM, Dave Hansen wrote:
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

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

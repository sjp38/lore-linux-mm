Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C03A6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:27:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l188so18059pfc.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 15:27:16 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 14si9689824pla.257.2017.10.10.15.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 15:27:15 -0700 (PDT)
Date: Tue, 10 Oct 2017 15:27:14 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v2] mm/page_alloc.c: inline __rmqueue()
Message-ID: <20171010222714.GE5109@tassilo.jf.intel.com>
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com>
 <20171010025601.GE1798@intel.com>
 <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
 <20171010054342.GF1798@intel.com>
 <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

> `inline' is basically advisory (or ignored) in modern gcc's.  So gcc
> has felt free to ignore it in __rmqueue_fallback and __rmqueue_smallest
> because gcc thinks it knows best.  That's why we created
> __always_inline, to grab gcc by the scruff of its neck.
> 
> So...  I think this patch could do with quite a bit more care, tuning
> and testing with various gcc versions.

We should just everything in the hot path mark __always_inline.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

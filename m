Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CFC596B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:42:00 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so16044289wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:42:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si18448703wje.157.2015.09.10.02.41.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 02:41:59 -0700 (PDT)
Subject: Re: [PATCHv5 4/7] mm: pack compound_dtor and compound_order into one
 word in struct page
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-5-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F15064.9040507@suse.cz>
Date: Thu, 10 Sep 2015 11:41:56 +0200
MIME-Version: 1.0
In-Reply-To: <1441283758-92774-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/03/2015 02:35 PM, Kirill A. Shutemov wrote:
> The patch halves space occupied by compound_dtor and compound_order in
> struct page.
> 
> For compound_order, it's trivial long -> short conversion.
> 
> For get_compound_page_dtor(), we now use hardcoded table for destructor
> lookup and store its index in the struct page instead of direct pointer
> to destructor. It shouldn't be a big trouble to maintain the table: we
> have only two destructor and NULL currently.
> 
> This patch free up one word in tail pages for reuse. This is preparation
> for the next patch.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

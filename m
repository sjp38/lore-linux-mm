Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 590B86B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 05:48:19 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so13786795lfq.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 02:48:19 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id f203si4246814lfe.186.2016.04.22.02.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 02:48:17 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id g184so76142535lfb.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 02:48:17 -0700 (PDT)
Date: Fri, 22 Apr 2016 12:48:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: move huge_pmd_set_accessed out of huge_memory.c
Message-ID: <20160422094815.GB7336@node.shutemov.name>
References: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
 <5717EDDB.1060704@linaro.org>
 <20160421073050.GA32611@node.shutemov.name>
 <57195A87.4050408@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57195A87.4050408@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Thu, Apr 21, 2016 at 03:56:07PM -0700, Shi, Yang wrote:
> On 4/21/2016 12:30 AM, Kirill A. Shutemov wrote:
> >On Wed, Apr 20, 2016 at 02:00:11PM -0700, Shi, Yang wrote:
> >>Hi folks,
> >>
> >>I didn't realize pmd_* functions are protected by
> >>CONFIG_TRANSPARENT_HUGEPAGE on the most architectures before I made this
> >>change.
> >>
> >>Before I fix all the affected architectures code, I want to check if you
> >>guys think this change is worth or not?
> >>
> >>Thanks,
> >>Yang
> >>
> >>On 4/20/2016 11:24 AM, Yang Shi wrote:
> >>>huge_pmd_set_accessed is only called by __handle_mm_fault from memory.c,
> >>>move the definition to memory.c and make it static like create_huge_pmd and
> >>>wp_huge_pmd.
> >>>
> >>>Signed-off-by: Yang Shi <yang.shi@linaro.org>
> >
> >On pte side we have the same functionality open-coded. Should we do the
> >same for pmd? Or change pte side the same way?
> 
> Sorry, I don't quite understand you. Do you mean pte_* functions?

See handle_pte_fault(), we do the same for pte there what
huge_pmd_set_accessed() does for pmd.

I think we should be consistent here: either both are abstructed into
functions or both open-coded.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

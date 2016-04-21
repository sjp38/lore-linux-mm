Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBB2F82F6B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 03:30:53 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id wy10so21962770lbb.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:30:53 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id ha3si1544012wjc.172.2016.04.21.00.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 00:30:52 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id v188so232276750wme.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:30:52 -0700 (PDT)
Date: Thu, 21 Apr 2016 10:30:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: move huge_pmd_set_accessed out of huge_memory.c
Message-ID: <20160421073050.GA32611@node.shutemov.name>
References: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
 <5717EDDB.1060704@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5717EDDB.1060704@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed, Apr 20, 2016 at 02:00:11PM -0700, Shi, Yang wrote:
> Hi folks,
> 
> I didn't realize pmd_* functions are protected by
> CONFIG_TRANSPARENT_HUGEPAGE on the most architectures before I made this
> change.
> 
> Before I fix all the affected architectures code, I want to check if you
> guys think this change is worth or not?
> 
> Thanks,
> Yang
> 
> On 4/20/2016 11:24 AM, Yang Shi wrote:
> >huge_pmd_set_accessed is only called by __handle_mm_fault from memory.c,
> >move the definition to memory.c and make it static like create_huge_pmd and
> >wp_huge_pmd.
> >
> >Signed-off-by: Yang Shi <yang.shi@linaro.org>

On pte side we have the same functionality open-coded. Should we do the
same for pmd? Or change pte side the same way?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

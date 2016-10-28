Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9D36B0289
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 17:26:59 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fl2so50406815pad.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 14:26:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x86si15193055pff.54.2016.10.28.14.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 14:26:58 -0700 (PDT)
Date: Fri, 28 Oct 2016 14:26:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Crash in -next due to 'mm/vmalloc: replace opencoded 4-level
 page walkers'
Message-Id: <20161028142657.3f4b23114737462043a4e109@linux-foundation.org>
In-Reply-To: <20161028201548.GA16450@nuc-i3427.alporthouse.com>
References: <20161028171825.GA15116@roeck-us.net>
	<20161028201548.GA16450@nuc-i3427.alporthouse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Guenter Roeck <linux@roeck-us.net>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 28 Oct 2016 21:15:48 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> > Bisect points to commit 0c79e3331f08 ("mm/vmalloc: replace opencoded 4-level
> > page walkers"). Reverting this patch fixes the problem.
> 
> Hmm, apply_to_pte_range() has a BUG_ON(pmd_huge(*pmd)) but the old
> vmap_pte_range() does not and neither has the code to handle that case.
> Presuming that the BUG_ON() there is actually meaningful.

Thanks, I'll drop mm-vmalloc-replace-opencoded-4-level-page-walkers.patch for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

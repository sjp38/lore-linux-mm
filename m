Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id A94196B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:53:15 -0400 (EDT)
Received: by lanb10 with SMTP id b10so7730378lan.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:53:15 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id qo1si1544916lbb.135.2015.09.17.02.53.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 02:53:14 -0700 (PDT)
Received: by lbpo4 with SMTP id o4so6404689lbp.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:53:14 -0700 (PDT)
Date: Thu, 17 Sep 2015 12:53:11 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150917095311.GH2000@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
 <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Thu, Sep 17, 2015 at 10:58:59AM +0200, Martin Schwidefsky wrote:
> Fixes a regression introduced with commit 179ef71cbc085252
> "mm: save soft-dirty bits on swapped pages"
> 
> The maybe_same_pte() function is used to match a swap pte independent
> of the swap software dirty bit set with pte_swp_mksoft_dirty().
> 
> For CONFIG_HAVE_ARCH_SOFT_DIRTY=y but CONFIG_MEM_SOFT_DIRTY=n the
> software dirty bit may be set but maybe_same_pte() will not recognize
> a software dirty swap pte. Due to this a 'swapoff -a' will hang.
> 
> The straightforward solution is to replace CONFIG_MEM_SOFT_DIRTY
> with HAVE_ARCH_SOFT_DIRTY in maybe_same_pte().
> 
> Cc: linux-mm@kvack.org
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Thanks a huge, Martin! I'll take a look today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
